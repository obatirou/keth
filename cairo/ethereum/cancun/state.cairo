from starkware.cairo.common.cairo_builtins import PoseidonBuiltin
from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.dict import dict_new
from starkware.cairo.common.registers import get_fp_and_pc
from starkware.cairo.common.math import assert_not_zero

from ethereum.cancun.fork_types import (
    Address,
    Account,
    MappingAddressAccount,
    SetAddress,
    EMPTY_ACCOUNT,
    MappingBytes32U256,
    MappingBytes32U256Struct,
    Bytes32U256DictAccess,
)
from ethereum.cancun.trie import (
    TrieBytes32U256,
    TrieAddressAccount,
    trie_get_TrieAddressAccount,
    trie_get_TrieBytes32U256,
    trie_set_TrieBytes32U256,
    AccountStruct,
    TrieBytes32U256Struct,
    TrieAddressAccountStruct,
    copy_trieAddressAccount,
    copy_trieBytes32U256,
)
from ethereum_types.bytes import Bytes, Bytes32
from ethereum_types.numeric import U256, U256Struct, Bool, bool
from ethereum.utils.numeric import is_zero

from src.utils.dict import hashdict_read, hashdict_write, hashdict_get

struct AddressTrieBytes32U256DictAccess {
    key: Address,
    prev_value: TrieBytes32U256,
    new_value: TrieBytes32U256,
}

struct MappingAddressTrieBytes32U256Struct {
    dict_ptr_start: AddressTrieBytes32U256DictAccess*,
    dict_ptr: AddressTrieBytes32U256DictAccess*,
    // In case this is a copy of a previous dict,
    // this field points to the address of the original mapping.
    original_mapping: MappingAddressTrieBytes32U256Struct*,
}

struct MappingAddressTrieBytes32U256 {
    value: MappingAddressTrieBytes32U256Struct*,
}

struct TupleTrieAddressAccountMappingAddressTrieBytes32U256Struct {
    trie_address_account: TrieAddressAccount,
    mapping_address_trie: MappingAddressTrieBytes32U256,
}

struct TupleTrieAddressAccountMappingAddressTrieBytes32U256 {
    value: TupleTrieAddressAccountMappingAddressTrieBytes32U256Struct*,
}

struct ListTupleTrieAddressAccountMappingAddressTrieBytes32U256Struct {
    data: TupleTrieAddressAccountMappingAddressTrieBytes32U256*,
    len: felt,
}

struct ListTupleTrieAddressAccountMappingAddressTrieBytes32U256 {
    value: ListTupleTrieAddressAccountMappingAddressTrieBytes32U256Struct*,
}

struct TransientStorageSnapshotsStruct {
    data: MappingAddressTrieBytes32U256*,
    len: felt,
}

struct TransientStorageSnapshots {
    value: TransientStorageSnapshotsStruct*,
}

struct TransientStorageStruct {
    _tries: MappingAddressTrieBytes32U256,
    _snapshots: TransientStorageSnapshots,
}

struct TransientStorage {
    value: TransientStorageStruct*,
}

struct StateStruct {
    _main_trie: TrieAddressAccount,
    _storage_tries: MappingAddressTrieBytes32U256,
    _snapshots: ListTupleTrieAddressAccountMappingAddressTrieBytes32U256,
    created_accounts: SetAddress,
}

struct State {
    value: StateStruct*,
}

using OptionalAccount = Account;
func get_account_optional{poseidon_ptr: PoseidonBuiltin*, state: State}(
    address: Address
) -> OptionalAccount {
    let trie = state.value._main_trie;
    with trie {
        let account = trie_get_TrieAddressAccount(address);
    }

    return account;
}

func get_account{poseidon_ptr: PoseidonBuiltin*, state: State}(address: Address) -> Account {
    let account = get_account_optional{state=state}(address);

    if (cast(account.value, felt) == 0) {
        let empty_account = EMPTY_ACCOUNT();
        return empty_account;
    }

    return account;
}

func get_storage{poseidon_ptr: PoseidonBuiltin*, state: State}(
    address: Address, key: Bytes32
) -> U256 {
    alloc_locals;
    let storage_tries = state.value._storage_tries;

    let fp_and_pc = get_fp_and_pc();
    local __fp__: felt* = fp_and_pc.fp_val;

    let storage_tries_dict_ptr = cast(storage_tries.value.dict_ptr, DictAccess*);

    // Use `hashdict_get` instead of `hashdict_read` because `MappingAddressTrieBytes32U256` is not a
    // `default_dict`. Accessing a key that does not exist in the dict would have panicked for `hashdict_read`.
    let (pointer) = hashdict_get{poseidon_ptr=poseidon_ptr, dict_ptr=storage_tries_dict_ptr}(
        1, &address.value
    );

    if (cast(pointer, felt) == 0) {
        // Early return if no associated Trie at address
        let new_storage_tries_dict_ptr = cast(
            storage_tries_dict_ptr, AddressTrieBytes32U256DictAccess*
        );
        tempvar storage_tries = MappingAddressTrieBytes32U256(
            new MappingAddressTrieBytes32U256Struct(
                dict_ptr_start=storage_tries.value.dict_ptr_start,
                dict_ptr=new_storage_tries_dict_ptr,
                original_mapping=storage_tries.value.original_mapping,
            ),
        );
        tempvar state = State(
            new StateStruct(
                _main_trie=state.value._main_trie,
                _storage_tries=storage_tries,
                _snapshots=state.value._snapshots,
                created_accounts=state.value.created_accounts,
            ),
        );

        tempvar res = U256(new U256Struct(0, 0));
        return res;
    }

    let storage_trie_ptr = cast(pointer, TrieBytes32U256Struct*);
    let storage_trie = TrieBytes32U256(storage_trie_ptr);
    let value = trie_get_TrieBytes32U256{poseidon_ptr=poseidon_ptr, trie=storage_trie}(key);

    // Rebind the storage trie to the state
    let new_storage_trie_ptr = cast(storage_trie.value, felt);

    hashdict_write{poseidon_ptr=poseidon_ptr, dict_ptr=storage_tries_dict_ptr}(
        1, &address.value, new_storage_trie_ptr
    );

    let new_storage_tries_dict_ptr = cast(
        storage_tries_dict_ptr, AddressTrieBytes32U256DictAccess*
    );
    tempvar storage_tries = MappingAddressTrieBytes32U256(
        new MappingAddressTrieBytes32U256Struct(
            dict_ptr_start=storage_tries.value.dict_ptr_start,
            dict_ptr=new_storage_tries_dict_ptr,
            original_mapping=storage_tries.value.original_mapping,
        ),
    );
    tempvar state = State(
        new StateStruct(
            _main_trie=state.value._main_trie,
            _storage_tries=storage_tries,
            _snapshots=state.value._snapshots,
            created_accounts=state.value.created_accounts,
        ),
    );
    return value;
}

func set_storage{poseidon_ptr: PoseidonBuiltin*, state: State}(
    address: Address, key: Bytes32, value: U256
) {
    alloc_locals;

    let storage_tries = state.value._storage_tries;
    let fp_and_pc = get_fp_and_pc();
    local __fp__: felt* = fp_and_pc.fp_val;

    // Assert that the account exists
    let account = get_account_optional(address);
    if (cast(account.value, felt) == 0) {
        // TODO: think about which cases lead to this error and decide on the correct type of exception to raise
        // perhaps AssertionError
        with_attr error_message("Cannot set storage on non-existent account") {
            assert 0 = 1;
        }
    }

    let storage_tries_dict_ptr = cast(storage_tries.value.dict_ptr, DictAccess*);
    // Use `hashdict_get` instead of `hashdict_read` because `MappingAddressTrieBytes32U256` is not a
    // `default_dict`. Accessing a key that does not exist in the dict would have panicked for `hashdict_read`.
    let (storage_trie_pointer) = hashdict_get{
        poseidon_ptr=poseidon_ptr, dict_ptr=storage_tries_dict_ptr
    }(1, &address.value);

    if (storage_trie_pointer == 0) {
        // dict_new expects an initial_dict hint argument.
        %{ initial_dict = {} %}
        let (new_mapping_dict_ptr) = dict_new();
        tempvar new_storage_trie = new TrieBytes32U256Struct(
            secured=bool(1),
            default=U256(new U256Struct(0, 0)),
            _data=MappingBytes32U256(
                new MappingBytes32U256Struct(
                    dict_ptr_start=cast(new_mapping_dict_ptr, Bytes32U256DictAccess*),
                    dict_ptr=cast(new_mapping_dict_ptr, Bytes32U256DictAccess*),
                    original_mapping=cast(0, MappingBytes32U256Struct*),
                ),
            ),
        );

        let storage_trie_pointer = cast(new_storage_trie, felt);
        hashdict_write{poseidon_ptr=poseidon_ptr, dict_ptr=storage_tries_dict_ptr}(
            1, &address.value, storage_trie_pointer
        );

        tempvar storage_trie_pointer = storage_trie_pointer;
    } else {
        tempvar storage_trie_pointer = storage_trie_pointer;
    }
    let storage_tries_dict_ptr = storage_tries_dict_ptr;

    let trie_struct = cast(storage_trie_pointer, TrieBytes32U256Struct*);
    let storage_trie = TrieBytes32U256(trie_struct);
    trie_set_TrieBytes32U256{poseidon_ptr=poseidon_ptr, trie=storage_trie}(key, value);

    // From EELS <https://github.com/ethereum/execution-specs/blob/master/src/ethereum/cancun/state.py#L318>:
    // if trie._data == {}:
    //     del state._storage_tries[address]
    // TODO: Investigate whether this is needed inside provable code
    // If the storage trie is empty, then write null ptr to the mapping address -> storage trie at address

    // Update state
    // 1. Write the updated storage trie to the mapping address -> storage trie
    let storage_trie_ptr = cast(storage_trie.value, felt);
    hashdict_write{poseidon_ptr=poseidon_ptr, dict_ptr=storage_tries_dict_ptr}(
        1, &address.value, storage_trie_ptr
    );
    // 2. Create a new storage_tries instance with the updated storage trie at address
    let new_storage_tries_dict_ptr = cast(
        storage_tries_dict_ptr, AddressTrieBytes32U256DictAccess*
    );
    tempvar new_storage_tries = MappingAddressTrieBytes32U256(
        new MappingAddressTrieBytes32U256Struct(
            dict_ptr_start=storage_tries.value.dict_ptr_start,
            dict_ptr=new_storage_tries_dict_ptr,
            original_mapping=storage_tries.value.original_mapping,
        ),
    );
    // 3. Update state with the updated storage tries
    tempvar state = State(
        new StateStruct(
            _main_trie=state.value._main_trie,
            _storage_tries=new_storage_tries,
            _snapshots=state.value._snapshots,
            created_accounts=state.value.created_accounts,
        ),
    );
    return ();
}

func get_transient_storage{poseidon_ptr: PoseidonBuiltin*, transient_storage: TransientStorage}(
    address: Address, key: Bytes32
) -> U256 {
    alloc_locals;
    let fp_and_pc = get_fp_and_pc();
    local __fp__: felt* = fp_and_pc.fp_val;

    let transient_storage_tries_dict_ptr = cast(
        transient_storage.value._tries.value.dict_ptr, DictAccess*
    );
    let (trie_ptr) = hashdict_get{dict_ptr=transient_storage_tries_dict_ptr}(1, &address.value);

    // If no storage trie is associated to that address, return the 0 default
    if (trie_ptr == 0) {
        let new_transient_storage_tries_dict_ptr = cast(
            transient_storage_tries_dict_ptr, AddressTrieBytes32U256DictAccess*
        );
        tempvar transient_storage_tries = MappingAddressTrieBytes32U256(
            new MappingAddressTrieBytes32U256Struct(
                transient_storage.value._tries.value.dict_ptr_start,
                new_transient_storage_tries_dict_ptr,
                transient_storage.value._tries.value.original_mapping,
            ),
        );
        tempvar transient_storage = TransientStorage(
            new TransientStorageStruct(transient_storage_tries, transient_storage.value._snapshots)
        );
        tempvar result = U256(new U256Struct(0, 0));
        return result;
    }

    let trie = TrieBytes32U256(cast(trie_ptr, TrieBytes32U256Struct*));
    with trie {
        let value = trie_get_TrieBytes32U256(key);
    }

    // Rebind the trie to the transient storage
    hashdict_write{poseidon_ptr=poseidon_ptr, dict_ptr=transient_storage_tries_dict_ptr}(
        1, &address.value, cast(trie.value, felt)
    );
    let new_storage_tries_dict_ptr = cast(
        transient_storage_tries_dict_ptr, AddressTrieBytes32U256DictAccess*
    );
    tempvar transient_storage_tries = MappingAddressTrieBytes32U256(
        new MappingAddressTrieBytes32U256Struct(
            transient_storage.value._tries.value.dict_ptr_start,
            new_storage_tries_dict_ptr,
            transient_storage.value._tries.value.original_mapping,
        ),
    );
    tempvar transient_storage = TransientStorage(
        new TransientStorageStruct(transient_storage_tries, transient_storage.value._snapshots)
    );

    return value;
}

func set_transient_storage{poseidon_ptr: PoseidonBuiltin*, transient_storage: TransientStorage}(
    address: Address, key: Bytes32, value: U256
) {
    alloc_locals;
    let fp_and_pc = get_fp_and_pc();
    local __fp__: felt* = fp_and_pc.fp_val;

    let transient_storage_tries_dict_ptr = cast(
        transient_storage.value._tries.value.dict_ptr, DictAccess*
    );
    let (trie_ptr) = hashdict_get{dict_ptr=transient_storage_tries_dict_ptr}(1, &address.value);

    if (trie_ptr == 0) {
        %{ initial_dict = {} %}
        let (empty_dict) = dict_new();
        tempvar new_trie = new TrieBytes32U256Struct(
            secured=Bool(1),
            default=U256(new U256Struct(0, 0)),
            _data=MappingBytes32U256(
                new MappingBytes32U256Struct(
                    dict_ptr_start=cast(empty_dict, Bytes32U256DictAccess*),
                    dict_ptr=cast(empty_dict, Bytes32U256DictAccess*),
                    original_mapping=cast(0, MappingBytes32U256Struct*),
                ),
            ),
        );
        let new_trie_ptr = cast(new_trie, felt);
        hashdict_write{poseidon_ptr=poseidon_ptr, dict_ptr=transient_storage_tries_dict_ptr}(
            1, &address.value, new_trie_ptr
        );
        tempvar trie_ptr = new_trie_ptr;
    } else {
        tempvar trie_ptr = trie_ptr;
    }

    let transient_storage_tries_dict_ptr = transient_storage_tries_dict_ptr;
    tempvar trie = TrieBytes32U256(cast(trie_ptr, TrieBytes32U256Struct*));
    with trie {
        trie_set_TrieBytes32U256{poseidon_ptr=poseidon_ptr}(key, value);
    }

    // Trie is not deleted if empty
    // From EELS https://github.com/ethereum/execution-specs/blob/5c82ed6ac3eb992c7d87320a3e771b5e852a06df/src/ethereum/cancun/state.py#L697:
    // if trie._data == {}:
    //    del transient_storage._tries[address]

    // Update the transient storage tries
    hashdict_write{poseidon_ptr=poseidon_ptr, dict_ptr=transient_storage_tries_dict_ptr}(
        1, &address.value, cast(trie.value, felt)
    );
    let new_storage_tries_dict_ptr = cast(
        transient_storage_tries_dict_ptr, AddressTrieBytes32U256DictAccess*
    );
    tempvar transient_storage_tries = MappingAddressTrieBytes32U256(
        new MappingAddressTrieBytes32U256Struct(
            transient_storage.value._tries.value.dict_ptr_start,
            new_storage_tries_dict_ptr,
            transient_storage.value._tries.value.original_mapping,
        ),
    );
    tempvar transient_storage = TransientStorage(
        new TransientStorageStruct(transient_storage_tries, transient_storage.value._snapshots)
    );

    return ();
}

func account_has_code_or_nonce{poseidon_ptr: PoseidonBuiltin*, state: State}(
    address: Address
) -> bool {
    let account = get_account(address);

    if (account.value.nonce.value != 0) {
        tempvar res = bool(1);
        return res;
    }

    if (account.value.code.value.len != 0) {
        tempvar res = bool(1);
        return res;
    }

    tempvar res = bool(0);
    return res;
}

func account_exists{poseidon_ptr: PoseidonBuiltin*, state: State}(address: Address) -> bool {
    let account = get_account_optional(address);

    if (cast(account.value, felt) == 0) {
        tempvar result = bool(0);
        return result;
    }
    tempvar result = bool(1);
    return result;
}

func is_account_empty{poseidon_ptr: PoseidonBuiltin*, state: State}(address: Address) -> bool {
    // Get the account at the address
    let account = get_account(address);

    // Check if nonce is 0, code is empty, and balance is 0
    if (account.value.nonce.value != 0) {
        tempvar res = bool(0);
        return res;
    }

    if (account.value.code.value.len != 0) {
        tempvar res = bool(0);
        return res;
    }

    if (account.value.balance.value.low != 0) {
        tempvar res = bool(0);
        return res;
    }

    if (account.value.balance.value.high != 0) {
        tempvar res = bool(0);
        return res;
    }

    tempvar res = bool(1);
    return res;
}

func begin_transaction{
    range_check_ptr,
    poseidon_ptr: PoseidonBuiltin*,
    state: State,
    transient_storage: TransientStorage,
}() {
    alloc_locals;

    let fp_and_pc = get_fp_and_pc();
    local __fp__: felt* = fp_and_pc.fp_val;

    // Copy the main trie
    let trie = state.value._main_trie;
    let copied_main_trie = copy_trieAddressAccount{trie=trie}();

    // Initialize a new storage tries mapping to be used in the snapshot
    %{ initial_dict = {} %}
    let (new_storage_tries_dict_ptr) = dict_new();
    tempvar new_storage_tries = MappingAddressTrieBytes32U256(
        new MappingAddressTrieBytes32U256Struct(
            dict_ptr_start=cast(new_storage_tries_dict_ptr, AddressTrieBytes32U256DictAccess*),
            dict_ptr=cast(new_storage_tries_dict_ptr, AddressTrieBytes32U256DictAccess*),
            original_mapping=cast(0, MappingAddressTrieBytes32U256Struct*),
        ),
    );

    // Iterate over storage tries and copy each in the new storage tries mapping
    let storage_tries_dict_start = cast(
        state.value._storage_tries.value.dict_ptr_start, DictAccess*
    );
    let storage_tries_dict_end = cast(state.value._storage_tries.value.dict_ptr, DictAccess*);
    tempvar current_dict_ptr = storage_tries_dict_start;

    loop_storage_tries:
    // Check if we've reached the end of the dictionary
    tempvar continue = 1 - is_zero(current_dict_ptr - storage_tries_dict_end);
    jmp end_loop_storage_tries if continue != 0;

    // Get the current entry
    let key = [cast(current_dict_ptr, AddressTrieBytes32U256DictAccess*)].key;
    let trie_ptr = [cast(current_dict_ptr, AddressTrieBytes32U256DictAccess*)].new_value;

    // Copy the trie
    tempvar trie_to_copy = TrieAddressAccount(cast(trie_ptr.value, TrieAddressAccountStruct*));
    let copied_trie = copy_trieAddressAccount{trie=trie_to_copy}();

    // Write to new storage tries mapping
    let new_storage_trie_ptr = cast(new_storage_tries.value.dict_ptr, DictAccess*);
    hashdict_write{poseidon_ptr=poseidon_ptr, dict_ptr=new_storage_trie_ptr}(
        1, &key.value, cast(copied_trie.value, felt)
    );

    // Move to next entry
    tempvar current_dict_ptr = current_dict_ptr + DictAccess.SIZE;
    jmp loop_storage_tries;

    end_loop_storage_tries:
    // Store in snapshots the copied main trie and the new storage tries mapping
    tempvar new_snapshot = TupleTrieAddressAccountMappingAddressTrieBytes32U256(
        new TupleTrieAddressAccountMappingAddressTrieBytes32U256Struct(
            trie_address_account=copied_main_trie, mapping_address_trie=new_storage_tries
        ),
    );

    // Update the snapshots list
    let current_snapshot = state.value._snapshots.value.data.value +
        state.value._snapshots.value.len;
    let current_snapshot_ptr = cast(current_snapshot, felt);
    assert [current_snapshot_ptr] = cast(new_snapshot.value, felt);

    tempvar new_snapshots = ListTupleTrieAddressAccountMappingAddressTrieBytes32U256(
        new ListTupleTrieAddressAccountMappingAddressTrieBytes32U256Struct(
            data=state.value._snapshots.value.data, len=state.value._snapshots.value.len + 1
        ),
    );

    // Update state with new snapshots
    tempvar state = State(
        new StateStruct(
            _main_trie=state.value._main_trie,
            _storage_tries=state.value._storage_tries,
            _snapshots=new_snapshots,
            created_accounts=state.value.created_accounts,
        ),
    );

    // Repeat for transient storage
    %{ initial_dict = {} %}
    let (new_transient_storage_tries_dict_ptr) = dict_new();
    tempvar new_transient_storage_tries = MappingAddressTrieBytes32U256(
        new MappingAddressTrieBytes32U256Struct(
            dict_ptr_start=cast(
                new_transient_storage_tries_dict_ptr, AddressTrieBytes32U256DictAccess*
            ),
            dict_ptr=cast(new_transient_storage_tries_dict_ptr, AddressTrieBytes32U256DictAccess*),
            original_mapping=cast(0, MappingAddressTrieBytes32U256Struct*),
        ),
    );

    // Iterate over transient storage tries
    let transient_storage_tries_dict_start = cast(
        transient_storage.value._tries.value.dict_ptr_start, DictAccess*
    );
    let transient_storage_tries_dict_end = cast(
        transient_storage.value._tries.value.dict_ptr, DictAccess*
    );
    tempvar current_dict_ptr = transient_storage_tries_dict_start;

    loop_transient_storage_tries:
    // Check if we've reached the end of the dictionary
    tempvar continue = 1 - is_zero(current_dict_ptr - transient_storage_tries_dict_end);
    jmp end_loop_transient_storage_tries if continue != 0;

    // Get the current entry
    let key = [cast(current_dict_ptr, AddressTrieBytes32U256DictAccess*)].key;
    let trie_ptr = [cast(current_dict_ptr, AddressTrieBytes32U256DictAccess*)].new_value;

    // Copy the trie
    let trie_to_copy_bytes32_u256 = TrieBytes32U256(cast(trie_ptr.value, TrieBytes32U256Struct*));
    let copied_trie_bytes32_u256 = copy_trieBytes32U256{trie=trie_to_copy_bytes32_u256}();

    // Write to new transient storage tries mapping
    let new_transient_storage_tries_dict_ptr = cast(
        new_transient_storage_tries.value.dict_ptr, DictAccess*
    );
    hashdict_write{poseidon_ptr=poseidon_ptr, dict_ptr=new_transient_storage_tries_dict_ptr}(
        1, &key.value, cast(copied_trie_bytes32_u256.value, felt)
    );

    // Move to next entry
    tempvar current_dict_ptr = current_dict_ptr + DictAccess.SIZE;
    jmp loop_transient_storage_tries;

    end_loop_transient_storage_tries:
    tempvar new_transient_snapshot = MappingAddressTrieBytes32U256(
        new MappingAddressTrieBytes32U256Struct(
            dict_ptr_start=new_transient_storage_tries.value.dict_ptr_start,
            dict_ptr=new_transient_storage_tries.value.dict_ptr,
            original_mapping=new_transient_storage_tries.value.original_mapping,
        ),
    );

    // Update the snapshots list using pointer arithmetic, similar to main state
    let current_transient_snapshot = transient_storage.value._snapshots.value.data +
        transient_storage.value._snapshots.value.len;
    let current_transient_snapshot_ptr = cast(current_transient_snapshot, felt);
    assert [current_transient_snapshot_ptr] = cast(new_transient_snapshot.value, felt);

    tempvar new_transient_snapshots = TransientStorageSnapshots(
        new TransientStorageSnapshotsStruct(
            data=transient_storage.value._snapshots.value.data,
            len=transient_storage.value._snapshots.value.len + 1,
        ),
    );

    // Update transient storage with new snapshots
    tempvar transient_storage = TransientStorage(
        new TransientStorageStruct(
            _tries=transient_storage.value._tries, _snapshots=new_transient_snapshots
        ),
    );

    return ();
}
