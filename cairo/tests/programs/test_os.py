import pytest

from src.utils.uint256 import int_to_uint256
from tests.utils.models import Account, Block, State, to_int


@pytest.fixture
def block():
    return Block.model_validate(
        {
            "blockHeader": {
                "baseFeePerGas": "0x0a",
                "blobGasUsed": "0x00",
                "bloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                "coinbase": "0x2adc25665018aa1fe0e6bc666dac8fc2697ff9ba",
                "difficulty": "0x00",
                "excessBlobGas": "0x00",
                "extraData": "0x00",
                "gasLimit": "0x0f4240",
                "gasUsed": "0x0156f8",
                "hash": "0x46e317ac1d4c1a14323d9ef994c0f0813c6a90af87113a872ca6bcfcea86edba",
                "mixHash": "0x0000000000000000000000000000000000000000000000000000000000020000",
                "nonce": "0x0000000000000000",
                "number": "0x01",
                "parentBeaconBlockRoot": "0x0000000000000000000000000000000000000000000000000000000000000000",
                "parentHash": "0x02a4bfb03275efd1bf926bcbccc1c12ef1ed723414c1196b75c33219355c7180",
                "receiptTrie": "0xf44202824894394d28fa6c8c8e3ef83e1adf05405da06240c2ce9ca461e843d1",
                "stateRoot": "0x2f79dbc20b78bcd7a771a9eb6b25a4af69724085c97be69a95ba91187e66a9c0",
                "timestamp": "0x64903c57",
                "transactionsTrie": "0x5f3c4c1da4f0b2351fbb60b9e720d481ce0706b5aa697f10f28efbbab54e6ac8",
                "uncleHash": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347",
                "withdrawalsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421",
            },
            "rlp": "0xf90306f9023ca002a4bfb03275efd1bf926bcbccc1c12ef1ed723414c1196b75c33219355c7180a01dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347942adc25665018aa1fe0e6bc666dac8fc2697ff9baa02f79dbc20b78bcd7a771a9eb6b25a4af69724085c97be69a95ba91187e66a9c0a05f3c4c1da4f0b2351fbb60b9e720d481ce0706b5aa697f10f28efbbab54e6ac8a0f44202824894394d28fa6c8c8e3ef83e1adf05405da06240c2ce9ca461e843d1b90100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008001830f4240830156f88464903c5700a000000000000000000000000000000000000000000000000000000000000200008800000000000000000aa056e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b4218080a00000000000000000000000000000000000000000000000000000000000000000f8c3f8c1800a830f424094000000000000000000000000000000000000c0de80b8600000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001ca0f225c2292ba248fe3ed544f7d45dd4172337ba41dc480c3b17af63e03d281dafa035360ae92ae767c1d0a9e0358e4398174b10eeea046bceedf323e7bf3b17c652c0c0",
            "transactions": [
                {
                    "data": "0x000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                    "gasLimit": "0x0f4240",
                    "gasPrice": "0x0a",
                    "nonce": "0x00",
                    "r": "0xf225c2292ba248fe3ed544f7d45dd4172337ba41dc480c3b17af63e03d281daf",
                    "s": "0x35360ae92ae767c1d0a9e0358e4398174b10eeea046bceedf323e7bf3b17c652",
                    "sender": "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b",
                    "to": "0x000000000000000000000000000000000000c0de",
                    "v": "0x1c",
                    "value": "0x00",
                },
                {
                    "data": "0x000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                    "gasLimit": "0x0f4240",
                    "gasPrice": "0x0a",
                    "nonce": "0x00",
                    "r": "0xf225c2292ba248fe3ed544f7d45dd4172337ba41dc480c3b17af63e03d281daf",
                    "s": "0x35360ae92ae767c1d0a9e0358e4398174b10eeea046bceedf323e7bf3b17c652",
                    "sender": "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b",
                    "to": "0x000000000000000000000000000000000000c0de",
                    "v": "0x1c",
                    "value": "0x00",
                },
            ],
            "uncleHeaders": [],
            "withdrawals": [],
        }
    )


@pytest.fixture
def account():
    return Account.model_validate(
        {
            "balance": "0x00",
            "code": "0x7fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebf5f527fc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedf6020527fe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff60405260786040356020355f35608a565b5f515f55602051600155604051600255005b5e56",
            "nonce": "0x01",
            "storage": {"0x1": "0xabde1"},
        }
    )


@pytest.fixture
def state():
    return State.model_validate(
        {
            "0x000000000000000000000000000000000000c0de": {
                "balance": "0x00",
                "code": "0x7fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebf5f527fc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedf6020527fe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff60405260786040356020355f35608a565b5f515f55602051600155604051600255005b5e56",
                "nonce": "0x01",
                "storage": {
                    "0x00": "0xa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebf",
                    "0x01": "0xc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedf",
                    "0x02": "0xe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff",
                },
            },
            "0x000f3df6d732807ef1319fb7b8bb8522d0beac02": {
                "balance": "0x00",
                "code": "0x3373fffffffffffffffffffffffffffffffffffffffe14604d57602036146024575f5ffd5b5f35801560495762001fff810690815414603c575f5ffd5b62001fff01545f5260205ff35b5f5ffd5b62001fff42064281555f359062001fff015500",
                "nonce": "0x01",
                "storage": {"0xf2": "0x64903c57"},
            },
            "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b": {
                "balance": "0x3b8d6450",
                "code": "0x",
                "nonce": "0x01",
                "storage": {},
            },
        }
    )


class TestOs:

    def test_os(self, cairo_run, block, state):
        cairo_run("test_os", block=block, state=state)

    def test_block(self, cairo_run, block):
        result = cairo_run("test_block", block=block)
        assert Block.model_validate(result) == block

    def test_account(self, cairo_run, account):
        result = cairo_run("test_account", account=account)
        # Storage needs to handle differently because of the hashing of the keys
        assert {
            k: int_to_uint256(to_int(v)) for k, v in result["storage"].items()
        } == account.storage
        result["storage"] = {}
        account.storage = {}

        assert Account.model_validate(result) == account

    def test_state(self, cairo_run, state):
        cairo_run("test_state", state=state)