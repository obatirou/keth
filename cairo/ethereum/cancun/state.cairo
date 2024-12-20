from ethereum_types.bytes import Bytes
from ethereum_types.numeric import U256

struct BytesU256DictAccess {
    key: Bytes,
    prev_value: U256,
    new_value: U256,
}

struct MappingBytesU256Struct {
    dict_ptr_start: BytesU256DictAccess*,
    dict_ptr: BytesU256DictAccess*,
}

struct MappingBytesU256 {
    value: MappingBytesU256Struct*,
}
