#pragma version 0.3.10
#pragma optimize gas
#pragma evm-version shanghai
"""
@title Curve Leverage Bot Factory
@license Apache 2.0
@author Volume.finance
"""

struct SwapInfo:
    route: address[11]
    swap_params: uint256[5][5]
    amount: uint256
    expected: uint256
    pools: address[5]

interface ControllerFactory:
    def get_controller(collateral: address) -> address: view
    def stablecoin() -> address: view
    def WETH() -> address: view

interface ERC20:
    def approve(_spender: address, _value: uint256) -> bool: nonpayable
    def transfer(_to: address, _value: uint256) -> bool: nonpayable
    def transferFrom(_from: address, _to: address, _value: uint256) -> bool: nonpayable

interface WrappedEth:
    def withdraw(amount: uint256): nonpayable

interface Bot:
    def create_loan_extended(collateral_amount: uint256, debt: uint256, N: uint256, callbacker: address, callback_args: DynArray[uint256,5]): nonpayable
    def repay_extended(callbacker: address, callback_args: DynArray[uint256,5]) -> uint256: nonpayable
    def state() -> uint256[4]: view
    def health() -> int256: view

interface CurveSwapRouter:
    def exchange(
        _route: address[11],
        _swap_params: uint256[5][5],
        _amount: uint256,
        _expected: uint256,
        _pools: address[5]=empty(address[5]),
        _receiver: address=msg.sender
    ) -> uint256: payable

event BotStarted:
    owner: address
    bot: address
    collateral: address
    collateral_amount: uint256
    debt: uint256
    N: uint256
    leverage: uint256
    deleverage_percentage: uint256
    health_threshold: uint256
    expire: uint256
    callbacker: address
    callback_args: DynArray[uint256, 5]

event BotRepayed:
    owner: address
    bot: address
    return_amount: uint256

event UpdateBlueprint:
    old_blueprint: address
    new_blueprint: address

event UpdateCompass:
    old_compass: address
    new_compass: address

event UpdateRefundWallet:
    old_refund_wallet: address
    new_refund_wallet: address

event SetPaloma:
    paloma: bytes32

event UpdateGasFee:
    old_gas_fee: uint256
    new_gas_fee: uint256

event UpdateServiceFeeCollector:
    old_service_fee_collector: address
    new_service_fee_collector: address

event UpdateServiceFee:
    old_service_fee: uint256
    new_service_fee: uint256

MAX_SIZE: constant(uint256) = 8
DENOMINATOR: constant(uint256) = 10**18
VETH: constant(address) = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
WETH: immutable(address)
CONTROLLER_FACTORY: immutable(address)
ROUTER: immutable(address)
STABLECOIN: immutable(address)
blueprint: public(address)
compass: public(address)
bot_to_owner: public(HashMap[address, address])
refund_wallet: public(address)
gas_fee: public(uint256)
service_fee_collector: public(address)
service_fee: public(uint256)
paloma: public(bytes32)

@external
def __init__(_blueprint: address, _compass: address, controller_factory: address, router: address, _refund_wallet: address, _gas_fee: uint256, _service_fee_collector: address, _service_fee: uint256):
    self.blueprint = _blueprint
    self.compass = _compass
    self.refund_wallet = _refund_wallet
    self.gas_fee = _gas_fee
    self.service_fee_collector = _service_fee_collector
    self.service_fee = _service_fee
    CONTROLLER_FACTORY = controller_factory
    ROUTER = router
    WETH = ControllerFactory(controller_factory).WETH()
    STABLECOIN = ControllerFactory(CONTROLLER_FACTORY).stablecoin()
    log UpdateCompass(empty(address), _compass)
    log UpdateBlueprint(empty(address), _blueprint)
    log UpdateRefundWallet(empty(address), _refund_wallet)
    log UpdateGasFee(empty(uint256), _gas_fee)
    log UpdateServiceFeeCollector(empty(address), _service_fee_collector)
    log UpdateServiceFee(empty(uint256), _service_fee)

@external
@payable
@nonreentrant('lock')
def create_bot(swap_infos: DynArray[SwapInfo, MAX_SIZE], collateral: address, debt: uint256, N: uint256, callbacker: address, callback_args: DynArray[uint256,5], leverage: uint256, deleverage_percentage: uint256, health_threshold: uint256, expire: uint256):
    _gas_fee: uint256 = self.gas_fee
    _service_fee: uint256 = self.service_fee
    controller: address = ControllerFactory(CONTROLLER_FACTORY).get_controller(collateral)
    collateral_amount: uint256 = 0
    _value: uint256 = msg.value
    for swap_info in swap_infos:
        last_index: uint256 = 0
        for i in range(6): # to the first
            last_index = unsafe_sub(10, unsafe_add(i, i))
            if swap_info.route[last_index] != empty(address):
                break
        assert swap_info.route[last_index] == collateral or (swap_info.route[last_index] == VETH and collateral == WETH), "Wrong path"
        amount: uint256 = swap_info.amount
        assert amount > 0, "Insuf deposit"
        if collateral == WETH:
            if swap_info.route[0] == VETH:
                assert _value >= amount, "Insuf deposit"
                _value = unsafe_sub(_value, amount)
            else:
                assert ERC20(swap_info.route[0]).transferFrom(msg.sender, self, amount, default_return_value=True), "TF fail"
                if swap_info.route[0] == WETH:
                    WrappedEth(WETH).withdraw(amount)
                else:
                    assert ERC20(swap_info.route[0]).approve(ROUTER, amount, default_return_value=True), "Ap fail"
                    amount = CurveSwapRouter(ROUTER).exchange(swap_info.route, swap_info.swap_params, amount, swap_info.expected, swap_info.pools, self)
        else:
            if swap_info.route[0] == VETH:
                assert _value >= amount, "Insuf deposit"
                _value = unsafe_sub(_value, amount)
                amount = CurveSwapRouter(ROUTER).exchange(swap_info.route, swap_info.swap_params, amount, swap_info.expected, swap_info.pools, self, value=amount)
            else:
                assert ERC20(swap_info.route[0]).transferFrom(msg.sender, self, amount, default_return_value=True), "TF fail"
                if swap_info.route[0] != collateral:
                    assert ERC20(swap_info.route[0]).approve(ROUTER, amount, default_return_value=True), "Ap fail"
                    amount = CurveSwapRouter(ROUTER).exchange(swap_info.route, swap_info.swap_params, amount, swap_info.expected, swap_info.pools, self)
        collateral_amount += amount
    if _value > _gas_fee:
        send(msg.sender, unsafe_sub(_value, _gas_fee))
    else:
        assert _value == _gas_fee, "Insuf deposit"
    send(self.refund_wallet, _gas_fee)
    bot: address = empty(address)
    _service_fee_amount: uint256 = 0
    if _service_fee > 0:
        _service_fee_amount = unsafe_div(collateral_amount * _service_fee, DENOMINATOR)
        collateral_amount = unsafe_sub(collateral_amount, _service_fee_amount)
    assert collateral_amount > 0, "Insuf deposit"
    if collateral == WETH:
        send(self.service_fee_collector, _service_fee_amount)
        bot = create_from_blueprint(self.blueprint, controller, WETH, msg.sender, collateral, STABLECOIN, value=collateral_amount, code_offset=3)
    else:
        bot = create_from_blueprint(self.blueprint, controller, WETH, msg.sender, collateral, STABLECOIN, code_offset=3)
        assert ERC20(collateral).transfer(bot, collateral_amount, default_return_value=True), "Tr fail"
        if _service_fee_amount > 0:
            assert ERC20(collateral).transfer(self.service_fee_collector, _service_fee_amount, default_return_value=True), "Tr fail"
    Bot(bot).create_loan_extended(collateral_amount, debt, N, callbacker, callback_args)
    self.bot_to_owner[bot] = msg.sender
    log BotStarted(msg.sender, bot, collateral, collateral_amount, debt, N, leverage, deleverage_percentage, health_threshold, expire, callbacker, callback_args)

@external
@nonreentrant('lock')
def repay_bot(bots: DynArray[address, MAX_SIZE], callbackers: DynArray[address, MAX_SIZE], callback_args: DynArray[DynArray[uint256,5], MAX_SIZE]):
    assert len(bots) == len(callbackers) and len(bots) == len(callback_args), "invalidate"
    if msg.sender == self.compass:
        assert convert(slice(msg.data, unsafe_sub(len(msg.data), 32), 32), bytes32) == self.paloma, "Unauthorized"
        for i in range(MAX_SIZE):
            if i >= len(bots):
                break
            bal: uint256 = Bot(bots[i]).repay_extended(callbackers[i], callback_args[i])
            log BotRepayed(self.bot_to_owner[bots[i]], bots[i], bal)
    else:
        for i in range(MAX_SIZE):
            if i >= len(bots):
                break
            owner: address = self.bot_to_owner[bots[i]]
            assert owner == msg.sender, "Unauthorized"
            bal: uint256 = Bot(bots[i]).repay_extended(callbackers[i], callback_args[i])
            log BotRepayed(owner, bots[i], bal)

@external
@view
def state(bot: address) -> uint256[4]:
    return Bot(bot).state()

@external
@view
def health(bot: address) -> int256:
    return Bot(bot).health()

@external
def update_compass(new_compass: address):
    assert msg.sender == self.compass and len(msg.data) == 68 and convert(slice(msg.data, 36, 32), bytes32) == self.paloma, "Unauthorized"
    self.compass = new_compass
    log UpdateCompass(msg.sender, new_compass)

@external
def update_blueprint(new_blueprint: address):
    assert msg.sender == self.compass and len(msg.data) == 68 and convert(slice(msg.data, 36, 32), bytes32) == self.paloma, "Unauthorized"
    old_blueprint:address = self.blueprint
    self.blueprint = new_blueprint
    log UpdateCompass(old_blueprint, new_blueprint)

@external
def set_paloma():
    assert msg.sender == self.compass and self.paloma == empty(bytes32) and len(msg.data) == 36, "Invalid"
    _paloma: bytes32 = convert(slice(msg.data, 4, 32), bytes32)
    self.paloma = _paloma
    log SetPaloma(_paloma)

@external
def update_refund_wallet(new_refund_wallet: address):
    assert msg.sender == self.compass and len(msg.data) == 68 and convert(slice(msg.data, 36, 32), bytes32) == self.paloma, "Unauthorized"
    old_refund_wallet: address = self.refund_wallet
    self.refund_wallet = new_refund_wallet
    log UpdateRefundWallet(old_refund_wallet, new_refund_wallet)

@external
def update_gas_fee(new_gas_fee: uint256):
    assert msg.sender == self.compass and len(msg.data) == 68 and convert(slice(msg.data, 36, 32), bytes32) == self.paloma, "Unauthorized"
    old_gas_fee: uint256 = self.gas_fee
    self.gas_fee = new_gas_fee
    log UpdateGasFee(old_gas_fee, new_gas_fee)

@external
def update_service_fee_collector(new_service_fee_collector: address):
    assert msg.sender == self.compass and len(msg.data) == 68 and convert(slice(msg.data, 36, 32), bytes32) == self.paloma, "Unauthorized"
    old_service_fee_collector: address = self.service_fee_collector
    self.service_fee_collector = new_service_fee_collector
    log UpdateServiceFeeCollector(old_service_fee_collector, new_service_fee_collector)

@external
def update_service_fee(new_service_fee: uint256):
    assert msg.sender == self.compass and len(msg.data) == 68 and convert(slice(msg.data, 36, 32), bytes32) == self.paloma, "Unauthorized"
    old_service_fee: uint256 = self.service_fee
    self.service_fee = new_service_fee
    log UpdateServiceFee(old_service_fee, new_service_fee)


@external
@payable
def __default__():
    pass