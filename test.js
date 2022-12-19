const fs = require("fs");

const wasmModule = new WebAssembly.Module(fs.readFileSync("types/pair.wasm"));
const wasmInstance = new WebAssembly.Instance(wasmModule, {});

const memory                                = wasmInstance.exports['memory'];
const offset_size                           = wasmInstance.exports['offset-size'];
const value_size                            = wasmInstance.exports['value-size'];
const pair_size                             = wasmInstance.exports['pair-size'];
const group_size                            = wasmInstance.exports['group-size'];
const page_size                             = wasmInstance.exports['page-size'];
const offset_size_bits                      = wasmInstance.exports['offset-size-bits'];
const value_size_bits                       = wasmInstance.exports['value-size-bits'];
const pair_size_bits                        = wasmInstance.exports['pair-size-bits'];
const group_size_bits                       = wasmInstance.exports['group-size-bits'];
const page_size_bits                        = wasmInstance.exports['page-size-bits'];
const memory_page_count                     = wasmInstance.exports['memory-page-count'];
const memory_active_page                    = wasmInstance.exports['memory-active-page'];
const memory_block_store                    = wasmInstance.exports['memory-block-store'];
const page_flags                            = wasmInstance.exports['page-flags'];
const page_free_count                       = wasmInstance.exports['page-free-count'];
const page_free_scan_current_group          = wasmInstance.exports['page-free-scan-current-group'];
const page_pair_bottom                      = wasmInstance.exports['page-pair-bottom'];
const page_next_free_pair                   = wasmInstance.exports['page-next-free-pair'];
const page_smudge_flags                     = wasmInstance.exports['page-smudge-flags'];
const page_freelist_head                    = wasmInstance.exports['page-freelist-head'];
const page_freelist_bottom                  = wasmInstance.exports['page-freelist-bottom'];
const page_freelist_top                     = wasmInstance.exports['page-freelist-top'];
const page_flag_frontier_closed             = wasmInstance.exports['page-flag-frontier-closed'];
const page_pair_flags_area                  = wasmInstance.exports['page-pair-flags-area'];
const page_pair_flags_byte_length           = wasmInstance.exports['page-pair-flags-byte-length'];
const page_initial_bottom                   = wasmInstance.exports['page-initial-bottom'];
const page_free_scan_end_group              = wasmInstance.exports['page-free-scan-end-group'];
const page_initial_free_count               = wasmInstance.exports['page-initial-free-count'];
const page_offset_mask                      = wasmInstance.exports['page-offset-mask'];
const pair_flag_reachable                   = wasmInstance.exports['pair-flag-reachable'];
const pair_flag_pending                     = wasmInstance.exports['pair-flag-pending'];
const pair_flags_mask                       = wasmInstance.exports['pair-flags-mask'];
const pair_smudge_shift                     = wasmInstance.exports['pair-smudge-shift'];
const smudge_flag_shift_mask                = wasmInstance.exports['smudge-flag-shift-mask'];
const max_trace_depth                       = wasmInstance.exports['max-trace-depth'];
const pair_flag_reachable_i64_group         = wasmInstance.exports['pair-flag-reachable-i64-group'];
const pair_page_offset_mask                 = wasmInstance.exports['pair-page-offset-mask'];
const pair_flag_addr_shift                  = wasmInstance.exports['pair-flag-addr-shift'];
const pair_flag_idx_mask                    = wasmInstance.exports['pair-flag-idx-mask'];
const pair_flag_idx_shift                   = wasmInstance.exports['pair-flag-idx-shift'];
const tag_mask                              = wasmInstance.exports['tag-mask'];
const tag_small_integer                     = wasmInstance.exports['tag-small-integer'];
const tag_block                             = wasmInstance.exports['tag-block'];
const tag_box                               = wasmInstance.exports['tag-box'];
const tag_char                              = wasmInstance.exports['tag-char'];
const tag_pair                              = wasmInstance.exports['tag-pair'];
const tag_procedure                         = wasmInstance.exports['tag-procedure'];
const tag_symbol                            = wasmInstance.exports['tag-symbol'];
const tag_singleton                         = wasmInstance.exports['tag-singleton'];
const EOF_OBJECT                            = wasmInstance.exports['#eof-object'];
const FALSE                                 = wasmInstance.exports['#false'];
const NULL                                  = wasmInstance.exports['#null'];
const TRUE                                  = wasmInstance.exports['#true'];
const blockvalue_type                       = wasmInstance.exports['blockvalue-type'];
const blockvalue_block                      = wasmInstance.exports['blockvalue-block'];
const set_blockvalue_block                  = wasmInstance.exports['set-blockvalue-block'];
const get_blockstore                        = wasmInstance.exports['get-blockstore'];
const set_blockstore                        = wasmInstance.exports['set-blockstore'];
const get_active_page                       = wasmInstance.exports['get-active-page'];
const activate_next_page                    = wasmInstance.exports['activate-next-page'];
const value_tag                             = wasmInstance.exports['value-tag'];
const pair_page_base                        = wasmInstance.exports['pair-page-base'];
const pair_page_offset                      = wasmInstance.exports['pair-page-offset'];
const get_pair_flags_location               = wasmInstance.exports['get-pair-flags-location'];
const get_pair_flags                        = wasmInstance.exports['get-pair-flags'];
const set_all_pair_flags                    = wasmInstance.exports['set-all-pair-flags'];
const set_pair_flag                         = wasmInstance.exports['set-pair-flag'];
const clear_pair_flag                       = wasmInstance.exports['clear-pair-flag'];
const mark_pair_reachable                   = wasmInstance.exports['mark-pair-reachable'];
const mark_pair_dirty                       = wasmInstance.exports['mark-pair-dirty'];
const mark_pair_scanned                     = wasmInstance.exports['mark-pair-scanned'];
const pair_smudge_flag_addr                 = wasmInstance.exports['pair-smudge-flag-addr'];
const pair_smudge_flag_shift                = wasmInstance.exports['pair-smudge-flag-shift'];
const set_group_smudge                      = wasmInstance.exports['set-group-smudge'];
const clear_group_smudge                    = wasmInstance.exports['clear-group-smudge'];
const mark_block_reachable                  = wasmInstance.exports['mark-block-reachable'];
const trace_value                           = wasmInstance.exports['trace-value'];
const trace_pair                            = wasmInstance.exports['trace-pair'];
const get_group_ready_pair_map              = wasmInstance.exports['get-group-ready-pair-map'];
const get_group_free_pair_map               = wasmInstance.exports['get-group-free-pair-map'];
const get_flag_group_pair_offset            = wasmInstance.exports['get-flag-group-pair-offset'];
const next_pair_offset                      = wasmInstance.exports['next-pair-offset'];
const get_ready_map_trace_depth             = wasmInstance.exports['get-ready-map-trace-depth'];
const trace_group                           = wasmInstance.exports['trace-group'];
const collection_step                       = wasmInstance.exports['collection-step'];
const begin_collection                      = wasmInstance.exports['begin-collection'];
const is_collection_complete                = wasmInstance.exports['collection-complete?'];
const end_collection                        = wasmInstance.exports['end-collection'];
const page_decr_free_count                  = wasmInstance.exports['page-decr-free-count'];
const fill_page_freelist_from_free_pair_map = wasmInstance.exports['fill-page-freelist-from-free-pair-map'];
const fill_page_freelist                    = wasmInstance.exports['fill-page-freelist'];
const page_alloc_freelist_pair              = wasmInstance.exports['page-alloc-freelist-pair'];
const is_page_frontier_closed               = wasmInstance.exports['page-frontier-closed?'];
const close_page_frontier                   = wasmInstance.exports['close-page-frontier'];
const page_alloc_frontier_pair              = wasmInstance.exports['page-alloc-frontier-pair'];
const alloc_pair                            = wasmInstance.exports['alloc-pair'];
const make_pair                             = wasmInstance.exports['make-pair'];
const car                                   = wasmInstance.exports['car'];
const cdr                                   = wasmInstance.exports['cdr'];
const init_block_list                       = wasmInstance.exports['init-block-list'];
const init_page                             = wasmInstance.exports['init-page'];
const blockstore_page_count                 = wasmInstance.exports['blockstore-page-count'];
const blockstore_block_count                = wasmInstance.exports['blockstore-block-count'];
const blockstore_relocation_offset          = wasmInstance.exports['blockstore-relocation-offset'];
const blockstore_relocation_block           = wasmInstance.exports['blockstore-relocation-block'];
const blockstore_current_relocation         = wasmInstance.exports['blockstore-current-relocation'];
const blockstore_end_block                  = wasmInstance.exports['blockstore-end-block'];
const blockstore_free_area                  = wasmInstance.exports['blockstore-free-area'];
const block_owner                           = wasmInstance.exports['block-owner'];
const block_length                          = wasmInstance.exports['block-length'];
const free_block_next_block                 = wasmInstance.exports['free-block-next-block'];
const block_header_length                   = wasmInstance.exports['block-header-length'];
const block_header_size                     = wasmInstance.exports['block-header-size'];
const blockstore_header_size                = wasmInstance.exports['blockstore-header-size'];
const get_blockstore_page_count             = wasmInstance.exports['get-blockstore-page-count'];
const get_blockstore_block_count            = wasmInstance.exports['get-blockstore-block-count'];
const get_blockstore_freelist               = wasmInstance.exports['get-blockstore-freelist'];
const get_blockstore_relocation_offset      = wasmInstance.exports['get-blockstore-relocation-offset'];
const get_blockstore_relocation_block       = wasmInstance.exports['get-blockstore-relocation-block'];
const get_blockstore_current_relocation     = wasmInstance.exports['get-blockstore-current-relocation'];
const get_blockstore_end_block              = wasmInstance.exports['get-blockstore-end-block'];
const get_blockstore_free_area              = wasmInstance.exports['get-blockstore-free-area'];
const set_blockstore_page_count             = wasmInstance.exports['set-blockstore-page-count'];
const set_blockstore_block_count            = wasmInstance.exports['set-blockstore-block-count'];
const set_blockstore_relocation_offset      = wasmInstance.exports['set-blockstore-relocation-offset'];
const set_blockstore_relocation_block       = wasmInstance.exports['set-blockstore-relocation-block'];
const set_blockstore_current_relocation     = wasmInstance.exports['set-blockstore-current-relocation'];
const set_blockstore_end_block              = wasmInstance.exports['set-blockstore-end-block'];
const set_blockstore_free_area              = wasmInstance.exports['set-blockstore-free-area'];
const get_block_owner                       = wasmInstance.exports['get-block-owner'];
const get_block_length                      = wasmInstance.exports['get-block-length'];
const get_next_free_block                   = wasmInstance.exports['get-next-free-block'];
const set_block_owner                       = wasmInstance.exports['set-block-owner'];
const set_block_length                      = wasmInstance.exports['set-block-length'];
const set_next_free_block                   = wasmInstance.exports['set-next-free-block'];
const get_block_size                        = wasmInstance.exports['get-block-size'];
const get_next_block                        = wasmInstance.exports['get-next-block'];
const is_free_block                         = wasmInstance.exports['is-free-block'];
const is_last_free_block                    = wasmInstance.exports['is-last-free-block'];
const get_blockstore_initial_block          = wasmInstance.exports['get-blockstore-initial-block'];
const get_blockstore_top                    = wasmInstance.exports['get-blockstore-top'];
const is_blockstore_freelist_empty          = wasmInstance.exports['is-blockstore-freelist-empty'];
const is_blockstore_relocating              = wasmInstance.exports['is-blockstore-relocating'];
const decr_blockstore_block_count           = wasmInstance.exports['decr-blockstore-block-count'];
const incr_blockstore_block_count           = wasmInstance.exports['incr-blockstore-block-count'];
const make_free_block                       = wasmInstance.exports['make-free-block'];
const init_blockstore                       = wasmInstance.exports['init-blockstore'];
const can_split_free_block                  = wasmInstance.exports['can-split-free-block'];
const split_free_block                      = wasmInstance.exports['split-free-block'];
const compact_block_freelist                = wasmInstance.exports['compact-block-freelist'];
const alloc_exact_freelist_block            = wasmInstance.exports['alloc-exact-freelist-block'];
const alloc_freelist_block                  = wasmInstance.exports['alloc-freelist-block'];
const calc_block_size                       = wasmInstance.exports['calc-block-size'];
const ensure_blockstore_alloc_top           = wasmInstance.exports['ensure-blockstore-alloc-top'];
const alloc_end_block                       = wasmInstance.exports['alloc-end-block'];
const alloc_block                           = wasmInstance.exports['alloc-block'];
const step_blockstore_compact               = wasmInstance.exports['step-blockstore-compact'];
const fill_relocation_block                 = wasmInstance.exports['fill-relocation-block'];
const make_relocation_block                 = wasmInstance.exports['make-relocation-block'];
const add_freelist_block                    = wasmInstance.exports['add-freelist-block'];
const begin_relocate_blockstore             = wasmInstance.exports['begin-relocate-blockstore'];
const step_relocate_blockstore              = wasmInstance.exports['step-relocate-blockstore'];
const end_relocate_blockstore               = wasmInstance.exports['end-relocate-blockstore'];

var uint8buffer = new Uint8Array(memory.buffer);
var uint16buffer = new Uint16Array(memory.buffer);
var uint32buffer = new Uint32Array(memory.buffer);

test_units = [
    {
        name: 'memory init',
        cases: [
            {
                name:      'page count',
                action:    () => uint16buffer[memory_page_count/2],
                expected:  1
            },
            {
                name:      'active page',
                action:    () => get_active_page(),
                expected:  0x10000
            }
        ],
    },
    {
        name: 'page init',
        setup: () => init_page(1),
        enable: true,
        cases: [
            {
                name:      'flags',
                action:    () => uint16buffer[(get_active_page() + page_flags)/2],
                expected:  0
            },
            {
                name:      'free count',
                action:    () => uint16buffer[(get_active_page() + page_free_count)/2],
                expected:  (page_size.value - page_initial_bottom.value)/pair_size.value - 1,
            },
            {
                name:      'free scan current group',
                action:    () => uint32buffer[(get_active_page() + page_free_scan_current_group)/4],
                expected:  get_active_page() + page_initial_bottom.value - group_size.value,
            },
            {
                name:      'pair bottom',
                action:    () => uint32buffer[(get_active_page() + page_pair_bottom)/4],
                expected:  get_active_page() + page_initial_bottom.value + pair_size.value,
            },
            {
                name:      'is frontier closed',
                action:    () => is_page_frontier_closed(get_active_page()),
                expected:  0,
            },
            {
                name:     'clear pair flags area low',
                setup:    () => (uint8buffer[get_active_page() + page_pair_flags_area.value] = -1, init_page(1)),
                action:   () => uint8buffer[get_active_page() + page_pair_flags_area.value],
                expected: 2, // block list head pair is initialized by init_page
            },
            {
                name:     'clear pair flags area high',
                setup:    () => (uint8buffer[get_active_page() + page_initial_bottom.value - 1] = -1, init_page(1)),
                action:   () => (init_page(1), uint8buffer[get_active_page() + page_initial_bottom.value - 1]),
                expected: 0,
            },
        ],
    },
    {
        name: 'pair flags',
        setup: () => init_page(1),
        enable: true,
        cases: [
            {
                name:       'pair flags location -- bottom',
                tear_down:  () => init_page(1),
                action:     () => get_pair_flags_location(get_active_page() + page_initial_bottom.value),
                expected:   [get_active_page() + page_pair_flags_area.value, 0],
            },
            {
                name:       'pair flags location -- bottom + 1',
                tear_down:  () => init_page(1),
                action:     () => get_pair_flags_location(get_active_page() + page_initial_bottom.value + pair_size.value),
                expected:   [get_active_page() + page_pair_flags_area.value, 2],
            },
            {
                name:       'pair flags location -- top - 1',
                tear_down:  () => init_page(1),
                action:     () => get_pair_flags_location(get_active_page() + page_size.value - 2*pair_size.value),
                expected:   [get_active_page() + page_initial_bottom.value - 1, 4],
            },
            {
                name:       'pair flags location -- top',
                tear_down:  () => init_page(1),
                action:     () => get_pair_flags_location(get_active_page() + page_size.value - pair_size.value),
                expected:   [get_active_page() + page_initial_bottom.value - 1, 6],
            },
            {
                name:       'get pair flags -- bottom',
                setup:      () => uint8buffer[get_active_page() + page_pair_flags_area.value] = 0x03,
                tear_down:  () => init_page(1),
                action:     () => get_pair_flags(get_active_page() + page_initial_bottom.value),
                expected:   3
            },
            {
                name:       'get pair flags -- bottom + 1',
                setup:      () => uint8buffer[get_active_page() + page_pair_flags_area.value] = 0x0c,
                tear_down:  () => init_page(1),
                action:     () => get_pair_flags(get_active_page() + page_initial_bottom.value + pair_size.value),
                expected:   3
            },
            {
                name:       'get pair flags -- top - 1',
                setup:      () => uint8buffer[get_active_page() + page_initial_bottom.value - 1] = 0x30,
                tear_down:  () => init_page(1),
                action:     () => get_pair_flags(get_active_page() + page_size.value - 2*pair_size.value),
                expected:   3,
            },
            {
                name:       'get pair flags -- top',
                setup:      () => uint8buffer[get_active_page() + page_initial_bottom.value - 1] = 0xc0,
                tear_down:  () => init_page(1),
                action:     () => get_pair_flags(get_active_page() + page_size.value - pair_size.value),
                expected:   3,
            },
            {
                name:       'get pair flags (specificity) -- bottom',
                setup:      () => uint8buffer[get_active_page() + page_pair_flags_area.value] = 0xfc,
                tear_down:  () => init_page(1),
                action:     () => get_pair_flags(get_active_page() + page_initial_bottom.value),
                expected:   0
            },
            {
                name:       'get pair flags (specificity) -- bottom + 1',
                setup:      () => uint8buffer[get_active_page() + page_pair_flags_area.value] = 0xf3,
                tear_down:  () => init_page(1),
                action:     () => get_pair_flags(get_active_page() + page_initial_bottom.value + pair_size.value),
                expected:   0
            },
            {
                name:       'get pair flags (specificity) -- top - 1',
                setup:      () => uint8buffer[get_active_page() + page_initial_bottom.value - 1] = 0xcf,
                tear_down:  () => init_page(1),
                action:     () => get_pair_flags(get_active_page() + page_size.value - 2*pair_size.value),
                expected:   0,
            },
            {
                name:       'get pair flags (specificity) -- top',
                setup:      () => uint8buffer[get_active_page() + page_initial_bottom.value - 1] = 0x3f,
                tear_down:  () => init_page(1),
                action:     () => get_pair_flags(get_active_page() + page_size.value - pair_size.value),
                expected:   0,
            },
            {
                name:       'set all pair flags -- bottom',
                setup:      () => set_all_pair_flags(get_active_page() + page_initial_bottom.value, 3),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_pair_flags_area.value],
                expected:   0x03
            },
            {
                name:       'set all pair flags -- bottom + 1',
                setup:      () => set_all_pair_flags(get_active_page() + page_initial_bottom.value + pair_size.value, 3),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_pair_flags_area.value],
                expected:   0x0e, // block list head pair is initialized by init_page => 0x02 is set
            },
            {
                name:       'set all pair flags -- top - 1',
                setup:      () => set_all_pair_flags(get_active_page() + page_size.value - 2*pair_size.value, 3),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_initial_bottom.value - 1],
                expected:   0x30
            },
            {
                name:       'set all pair flags -- top',
                setup:      () => set_all_pair_flags(get_active_page() + page_size.value - pair_size.value, 3),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_initial_bottom.value - 1],
                expected:   0xc0
            },
            {
                name:       'set all pair flags (specificity) -- bottom',
                setup:      () => set_all_pair_flags(get_active_page() + page_initial_bottom.value, -1),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_pair_flags_area.value],
                expected:   0x03
            },
            {
                name:       'set all pair flags (specificity) -- bottom + 1',
                setup:      () => set_all_pair_flags(get_active_page() + page_initial_bottom.value + pair_size.value, -1),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_pair_flags_area.value],
                expected:   0x0e, // block list head pair is initialized by init_page => 0x02 is set
            },
            {
                name:       'set all pair flags (specificity) -- top - 1',
                setup:      () => set_all_pair_flags(get_active_page() + page_size.value - 2*pair_size.value, -1),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_initial_bottom.value - 1],
                expected:   0x30
            },
            {
                name:       'set all pair flags (specificity) -- top',
                setup:      () => set_all_pair_flags(get_active_page() + page_size.value - pair_size.value, -1),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_initial_bottom.value - 1],
                expected:   0xc0
            },
            {
                name:       'set all pair flags (internal specificity) -- bottom',
                setup:      () => set_all_pair_flags(get_active_page() + page_initial_bottom.value, 0),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_pair_flags_area.value],
                expected:   0x00
            },
            {
                name:       'set all pair flags (internal specificity) -- bottom + 1',
                setup:      () => set_all_pair_flags(get_active_page() + page_initial_bottom.value + pair_size.value, 1),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_pair_flags_area.value],
                expected:   0x06, // block list head pair is initialized by init_page => 0x02 is set
            },
            {
                name:       'set all pair flags (internal specificity) -- top - 1',
                setup:      () => set_all_pair_flags(get_active_page() + page_size.value - 2*pair_size.value, 2),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_initial_bottom.value - 1],
                expected:   0x20
            },
            {
                name:       'set all pair flags (internal specificity) -- top',
                setup:      () => set_all_pair_flags(get_active_page() + page_size.value - pair_size.value, 3),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_initial_bottom.value - 1],
                expected:   0xc0
            },
            {
                name:       'set pair flag -- bottom',
                setup:      () => set_pair_flag(get_active_page() + page_initial_bottom.value, 3),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_pair_flags_area.value],
                expected:   0x03
            },
            {
                name:       'set pair flag -- bottom + 1',
                setup:      () => set_pair_flag(get_active_page() + page_initial_bottom.value + pair_size.value, 3),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_pair_flags_area.value],
                expected:   0x0e, // block list head pair is initialized by init_page => 0x02 is set
            },
            {
                name:       'set pair flag -- top - 1',
                setup:      () => set_pair_flag(get_active_page() + page_size.value - 2*pair_size.value, 3),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_initial_bottom.value - 1],
                expected:   0x30
            },
            {
                name:       'set pair flag -- top',
                setup:      () => set_pair_flag(get_active_page() + page_size.value - pair_size.value, 3),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_initial_bottom.value - 1],
                expected:   0xc0
            },
            {
                name:       'set pair flag (specificity) -- bottom',
                setup:      () => set_pair_flag(get_active_page() + page_initial_bottom.value, -1),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_pair_flags_area.value],
                expected:   0x03
            },
            {
                name:       'set pair flag (specificity) -- bottom + 1',
                setup:      () => set_pair_flag(get_active_page() + page_initial_bottom.value + pair_size.value, -1),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_pair_flags_area.value],
                expected:   0x0e, // block list head pair is initialized by init_page => 0x02 is set
            },
            {
                name:       'set pair flag (specificity) -- top - 1',
                setup:      () => set_pair_flag(get_active_page() + page_size.value - 2*pair_size.value, -1),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_initial_bottom.value - 1],
                expected:   0x30
            },
            {
                name:       'set pair flag (specificity) -- top',
                setup:      () => set_pair_flag(get_active_page() + page_size.value - pair_size.value, -1),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_initial_bottom.value - 1],
                expected:   0xc0
            },
            {
                name:       'set pair flag (internal specificity) -- bottom',
                setup:      () => set_pair_flag(get_active_page() + page_initial_bottom.value, 0),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_pair_flags_area.value],
                expected:   0x02, // block list head pair is initialized by init_page => 0x02 is set
            },
            {
                name:       'set pair flag (internal specificity) -- bottom + 1',
                setup:      () => set_pair_flag(get_active_page() + page_initial_bottom.value + pair_size.value, 1),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_pair_flags_area.value],
                expected:   0x06, // block list head pair is initialized by init_page => 0x02 is set
            },
            {
                name:       'set pair flag (internal specificity) -- top - 1',
                setup:      () => set_pair_flag(get_active_page() + page_size.value - 2*pair_size.value, 2),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_initial_bottom.value - 1],
                expected:   0x20
            },
            {
                name:       'set pair flag (internal specificity) -- top',
                setup:      () => set_pair_flag(get_active_page() + page_size.value - pair_size.value, 3),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_initial_bottom.value - 1],
                expected:   0xc0
            },
            {
                name:       'clear pair flag -- bottom',
                setup:      () => (set_pair_flag(get_active_page() + page_initial_bottom.value, 3), clear_pair_flag(get_active_page() + page_initial_bottom.value, 3)),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_pair_flags_area.value],
                expected:   0
            },
            {
                name:       'clear pair flag -- bottom + 1',
                setup:      () => (set_pair_flag(get_active_page() + page_initial_bottom.value + pair_size.value, 3), clear_pair_flag(get_active_page() + page_initial_bottom.value + pair_size.value, 3)),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_pair_flags_area.value],
                expected:   0x02, // block list head pair is initialized by init_page => 0x02 is set
           },
            {
                name:       'clear pair flag -- top - 1',
                setup:      () => (set_pair_flag(get_active_page() + page_size.value - 2*pair_size.value, 3), clear_pair_flag(get_active_page() + page_size.value - 2*pair_size.value, 3)),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_initial_bottom.value - 1],
                expected:   0
            },
            {
                name:       'clear pair flag -- top',
                setup:      () => (set_pair_flag(get_active_page() + page_size.value - pair_size.value, 3), clear_pair_flag(get_active_page() + page_size.value - pair_size.value, 3)),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_initial_bottom.value - 1],
                expected:   0
            },
            {
                name:       'clear pair flag -- bottom (specificity)',
                setup:      () => (uint8buffer[get_active_page() + page_pair_flags_area.value] = -1, clear_pair_flag(get_active_page() + page_initial_bottom.value, 3)),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_pair_flags_area.value],
                expected:   0xfc
            },
            {
                name:       'clear pair flag -- bottom + 1 (specificity)',
                setup:      () => (uint8buffer[get_active_page() + page_pair_flags_area.value] = -1, clear_pair_flag(get_active_page() + page_initial_bottom.value + pair_size.value, 3)),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_pair_flags_area.value],
                expected:   0xf3
           },
            {
                name:       'clear pair flag -- top - 1 (specificity)',
                setup:      () => (uint8buffer[get_active_page() + page_initial_bottom.value - 1] = -1, clear_pair_flag(get_active_page() + page_size.value - 2*pair_size.value, 3)),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_initial_bottom.value - 1],
                expected:   0xcf
            },
            {
                name:       'clear pair flag -- top (specificity)',
                setup:      () => (uint8buffer[get_active_page() + page_initial_bottom.value - 1] = -1, clear_pair_flag(get_active_page() + page_size.value - pair_size.value, 3)),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_initial_bottom.value - 1],
                expected:   0x3f
            },
            {
                name:       'clear pair flag -- bottom (internal specificity)',
                setup:      () => (set_pair_flag(get_active_page() + page_initial_bottom.value, 3), clear_pair_flag(get_active_page() + page_initial_bottom.value, 0)),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_pair_flags_area.value],
                expected:   0x03
            },
            {
                name:       'clear pair flag -- bottom + 1 (internal specificity)',
                setup:      () => (set_pair_flag(get_active_page() + page_initial_bottom.value + pair_size.value, 3), clear_pair_flag(get_active_page() + page_initial_bottom.value + pair_size.value, 1)),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_pair_flags_area.value],
                expected:   0x0a // block list head pair is initialized by init_page => 0x02 is set
           },
            {
                name:       'clear pair flag -- top - 1 (internal specificity)',
                setup:      () => (set_pair_flag(get_active_page() + page_size.value - 2*pair_size.value, 3), clear_pair_flag(get_active_page() + page_size.value - 2*pair_size.value, 2)),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_initial_bottom.value - 1],
                expected:   0x10
            },
            {
                name:       'clear pair flag -- top (internal specificity)',
                setup:      () => (set_pair_flag(get_active_page() + page_size.value - pair_size.value, 3), clear_pair_flag(get_active_page() + page_size.value - pair_size.value, 3)),
                tear_down:  () => init_page(1),
                action:     () => uint8buffer[get_active_page() + page_initial_bottom.value - 1],
                expected:   0x00
            },
            {
                name:       'mark pair reachable',
                setup:      () => mark_pair_reachable(get_active_page() + page_size.value - pair_size.value),
                tear_down:  () => init_page(1),
                action:     () => get_pair_flags(get_active_page() + page_size.value - pair_size.value),
                expected:   pair_flag_reachable.value
            },
            {
                name:       'mark pair dirty',
                setup:      () => mark_pair_dirty(get_active_page() + page_size.value - pair_size.value),
                tear_down:  () => init_page(1),
                action:     () => get_pair_flags(get_active_page() + page_size.value - pair_size.value),
                expected:   pair_flag_pending.value
            },
            {
                name:       'mark pair scanned',
                setup:      () => (mark_pair_dirty(get_active_page() + page_size.value - pair_size.value), mark_pair_scanned(get_active_page() + page_size.value - pair_size.value)),
                tear_down:  () => init_page(1),
                action:     () => get_pair_flags(get_active_page() + page_size.value - pair_size.value),
                expected:   0
            },
        ],
    },
    {
        name: 'fill freelist',
        enable: true,
        setup: () => init_page(1),
        cases: [
            {
                name:        'fill page freelist from free pair map -- empty',
                setup:       () => fill_page_freelist_from_free_pair_map(get_active_page(), get_active_page() + page_pair_flags_area.value, 0n),
                tear_down:   () => init_page(1),
                action:      () => uint16buffer.slice((get_active_page() + page_freelist_bottom)/2, (get_active_page() + page_pair_flags_area)/2),
                expected:    new Uint16Array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
            },
            {
                name:        'fill page freelist from free pair map -- bottom, lowest',
                setup:       () => fill_page_freelist_from_free_pair_map(get_active_page(), get_active_page() + page_pair_flags_area.value, 1n),
                tear_down:   () => init_page(1),
                action:      () => uint16buffer.slice((get_active_page() + page_freelist_bottom)/2, (get_active_page() + page_pair_flags_area)/2),
                expected:    new Uint16Array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, page_initial_bottom.value])
            },
            {
                name:        'fill page freelist from free pair map -- bottom, lowest + 1',
                setup:       () => fill_page_freelist_from_free_pair_map(get_active_page(), get_active_page() + page_pair_flags_area.value, 4n),
                tear_down:   () => init_page(1),
                action:      () => uint16buffer.slice((get_active_page() + page_freelist_bottom)/2, (get_active_page() + page_pair_flags_area)/2),
                expected:    new Uint16Array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, page_initial_bottom.value + pair_size.value])
            },
            {
                name:        'fill page freelist from free pair map -- bottom, lowest and lowest + 1',
                setup:       () => fill_page_freelist_from_free_pair_map(get_active_page(), get_active_page() + page_pair_flags_area.value, 5n),
                tear_down:   () => init_page(1),
                action:      () => uint16buffer.slice((get_active_page() + page_freelist_bottom)/2, (get_active_page() + page_pair_flags_area)/2),
                expected:    new Uint16Array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, page_initial_bottom.value + pair_size.value, page_initial_bottom.value])
            },
            {
                name:        'fill page freelist from free pair map -- bottom, lowest and highest',
                setup:       () => fill_page_freelist_from_free_pair_map(get_active_page(), get_active_page() + page_pair_flags_area.value, 1n + (1n << 62n)),
                tear_down:   () => init_page(1),
                action:      () => uint16buffer.slice((get_active_page() + page_freelist_bottom)/2, (get_active_page() + page_pair_flags_area)/2),
                expected:    new Uint16Array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, page_initial_bottom.value + pair_size.value * 31, page_initial_bottom.value])
            },
            {
                name:        'fill page freelist from free pair map -- top, lowest',
                setup:       () => fill_page_freelist_from_free_pair_map(get_active_page(), get_active_page() + page_initial_bottom.value - 8, 1n),
                tear_down:   () => init_page(1),
                action:      () => uint16buffer.slice((get_active_page() + page_freelist_bottom)/2, (get_active_page() + page_pair_flags_area)/2),
                expected:    new Uint16Array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, page_size.value - 32 * pair_size.value])
            },
            {
                name:        'fill page freelist from free pair map -- top, lowest + 1',
                setup:       () => fill_page_freelist_from_free_pair_map(get_active_page(), get_active_page() + page_initial_bottom.value - 8, 4n),
                tear_down:   () => init_page(1),
                action:      () => uint16buffer.slice((get_active_page() + page_freelist_bottom)/2, (get_active_page() + page_pair_flags_area)/2),
                expected:    new Uint16Array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, page_size.value - 31 * pair_size.value])
            },
            {
                name:        'fill page freelist from free pair map -- top, lowest and lowest + 1',
                setup:       () => fill_page_freelist_from_free_pair_map(get_active_page(), get_active_page() + page_initial_bottom.value - 8, 5n),
                tear_down:   () => init_page(1),
                action:      () => uint16buffer.slice((get_active_page() + page_freelist_bottom)/2, (get_active_page() + page_pair_flags_area)/2),
                expected:    new Uint16Array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, page_size.value - 31 * pair_size.value, page_size.value - 32 * pair_size.value])
            },
            {
                name:        'fill page freelist from free pair map -- top, lowest and highest',
                setup:       () => fill_page_freelist_from_free_pair_map(get_active_page(), get_active_page() + page_initial_bottom.value - 8, 1n + (1n << 62n)),
                tear_down:   () => init_page(1),
                action:      () => uint16buffer.slice((get_active_page() + page_freelist_bottom)/2, (get_active_page() + page_pair_flags_area)/2),
                expected:    new Uint16Array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, page_size.value - pair_size.value, page_size.value - 32 * pair_size.value])
            },
            {
                name:        'fill page freelist from free pair map -- top, highest',
                setup:       () => fill_page_freelist_from_free_pair_map(get_active_page(), get_active_page() + page_initial_bottom.value - 8, (1n << 62n)),
                tear_down:   () => init_page(1),
                action:      () => uint16buffer.slice((get_active_page() + page_freelist_bottom)/2, (get_active_page() + page_pair_flags_area)/2),
                expected:    new Uint16Array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, page_size.value - pair_size.value])
            },
        ],
    },
    {
        name: 'get group free pair map',
        enable: true,
        cases: [
            {
                name:        'empty',
                action:      () => get_group_free_pair_map(0n),
                expected:    0x5555555555555555n,
            },
            {
                name:        'all pending and reachable',
                action:      () => get_group_free_pair_map(0xffffffffffffffffn),
                expected:    0n,
            },
            {
                name:        'all reachable',
                action:      () => get_group_free_pair_map(0x5555555555555555n),
                expected:    0n,
            },
            {
                name:        'all pending',
                action:      () => get_group_free_pair_map(0xaaaaaaaaaaaaaaaan),
                expected:    0n,
            },
            {
                name:        'all pending but least',
                action:      () => get_group_free_pair_map(0xaaaaaaaaaaaaaaa8n),
                expected:    1n,
            },
            {
                name:        'all pending but greatest',
                action:      () => get_group_free_pair_map(0x2aaaaaaaaaaaaaaan),
                expected:    1n << 62n,
            },
            {
                name:        'all reachable but least',
                action:      () => get_group_free_pair_map(0x5555555555555554n),
                expected:    1n,
            },
            {
                name:        'all reachable but greatest',
                action:      () => get_group_free_pair_map(0x1555555555555555n),
                expected:    1n << 62n,
            },
        ],
    },
    {
        name: 'fill page freelist',
        cases: [
            {
                name:      'everything free -- check offsets',
                setup:     () => (init_page(1), fill_page_freelist(get_active_page())),
                tear_down: () => init_page(1),
                action:    () => [uint16buffer[(get_active_page() + page_pair_flags_area - 2)/2], uint16buffer[(get_active_page() + page_freelist_bottom)/2]],
                expected:  [page_size.value - 32 * pair_size.value, page_size.value - (32 - (page_pair_flags_area - page_freelist_bottom - 2)/2)  * pair_size.value],
            },
            {
                name:      'everything free -- check freelist head',
                setup:     () => (init_page(1), fill_page_freelist(get_active_page())),
                tear_down: () => init_page(1),
                action:    () => uint32buffer[(get_active_page() + page_freelist_head)/4],
                expected:  get_active_page() + page_freelist_bottom,
            },
            {
                name:      'nothing free -- check offsets',
                setup:     () => (init_page(1), uint8buffer.fill(0xff, get_active_page() + page_pair_flags_area, get_active_page() + page_initial_bottom), fill_page_freelist(get_active_page())),
                tear_down: () => init_page(1),
                action:    () => [uint16buffer[(get_active_page() + page_pair_flags_area - 2)/2], uint16buffer[(get_active_page() + page_freelist_bottom)/2]],
                expected:  [0, 0],
            },
            {
                name:      'nothing free -- check freelist head',
                setup:     () => (init_page(1), uint8buffer.fill(0xff, get_active_page() + page_pair_flags_area, get_active_page() + page_initial_bottom), fill_page_freelist(get_active_page())),
                tear_down: () => init_page(1),
                action:    () => uint32buffer[(get_active_page() + page_freelist_head)/4],
                expected:  get_active_page() + page_freelist_top,
            },
            {
                name:      'top and bottom free -- check offsets',
                setup:     () => (init_page(1),
                                  uint8buffer.fill(0xff, get_active_page() + page_pair_flags_area + 1, get_active_page() + page_initial_bottom - 1),
                                  fill_page_freelist(get_active_page())),
                tear_down: () => init_page(1),
                action:    () => uint16buffer.slice(uint32buffer[(get_active_page() + page_freelist_head)/4]/2, (get_active_page() + page_freelist_top)/2),
                expected:  new Uint16Array([
                    page_initial_bottom + 3 * pair_size,
                    page_initial_bottom + 2 * pair_size,
                    page_initial_bottom + pair_size,
                    // page_initial_bottom is taken by the blocklist head
                    page_size - pair_size,
                    page_size - 2 * pair_size,
                    page_size - 3 * pair_size,
                    page_size - 4 * pair_size,
                ]),
            },
            {
                name:      'top and bottom free -- check freelist head',
                setup:     () => (init_page(1),
                                  uint8buffer.fill(0xff, get_active_page() + page_pair_flags_area + 1, get_active_page() + page_initial_bottom - 1),
                                  fill_page_freelist(get_active_page())),
                tear_down: () => init_page(1),
                action:    () => uint32buffer[(get_active_page() + page_freelist_head)/4],
                expected:  get_active_page() + page_freelist_top - 7 * offset_size,
            },
        ],
    },
    {
        name: 'freelist alloc',
        cases: [
            {
                name:      'top and bottom free -- first alloc',
                setup:     () => (init_page(1),
                                  uint8buffer.fill(0xff, get_active_page() + page_pair_flags_area, get_active_page() + page_initial_bottom),
                                  (uint8buffer[get_active_page() + page_pair_flags_area] = 0xfc),
                                  (uint8buffer[get_active_page() + page_initial_bottom - 1] = 0x3f)),
                tear_down: () => init_page(1),
                action:    () => page_alloc_freelist_pair(get_active_page()),
                expected:  get_active_page() + page_initial_bottom,
            },
            {
                name:      'top and bottom free -- second alloc',
                setup:     () => (init_page(1),
                                  uint8buffer.fill(0xff, get_active_page() + page_pair_flags_area, get_active_page() + page_initial_bottom),
                                  (uint8buffer[get_active_page() + page_pair_flags_area] = 0xfc),
                                  (uint8buffer[get_active_page() + page_initial_bottom - 1] = 0x3f),
                                  page_alloc_freelist_pair(get_active_page())),
                tear_down: () => init_page(1),
                action:    () => page_alloc_freelist_pair(get_active_page()),
                expected:  get_active_page() + page_size - pair_size,
            },
            {
                name:      'top and bottom free -- third alloc',
                setup:     () => (init_page(1),
                                  uint8buffer.fill(0xff, get_active_page() + page_pair_flags_area, get_active_page() + page_initial_bottom),
                                  (uint8buffer[get_active_page() + page_pair_flags_area] = 0xfc),
                                  (uint8buffer[get_active_page() + page_initial_bottom - 1] = 0x3f),
                                  page_alloc_freelist_pair(get_active_page()),
                                  page_alloc_freelist_pair(get_active_page())),
                tear_down: () => init_page(1),
                action:    () => page_alloc_freelist_pair(get_active_page()),
                expected:  NULL.value,
            },
            {
                name:      'top and bottom free -- check free count',
                setup:     () => (init_page(1),
                                  uint8buffer.fill(0xff, get_active_page() + page_pair_flags_area, get_active_page() + page_initial_bottom),
                                  (uint8buffer[get_active_page() + page_pair_flags_area] = 0xfc),
                                  (uint8buffer[get_active_page() + page_initial_bottom - 1] = 0x3f),
                                  (uint16buffer[(get_active_page() + page_free_count)/2] = 1),
                                  page_alloc_freelist_pair(get_active_page())),
                tear_down: () => init_page(1),
                action:    () => uint16buffer[(get_active_page() + page_free_count)/2],
                expected:  0,
            },
        ],
    },
    {
        name: 'frontier alloc',
        enable: true,
        cases: [
            {
                name:        'alloc frontier pair',
                tear_down:   () => init_page(1),
                action:      () => get_pair_flags(page_alloc_frontier_pair(get_active_page())),
                expected:    pair_flag_pending.value,
            },
        ]
    },
    {
        name: 'alloc pair',
        enable: true,
        cases: [
            {
                name:        'check flags',
                setup:       () => alloc_pair(),
                tear_down:   () => init_page(1),
                action:      () => get_pair_flags(alloc_pair()),
                expected:    pair_flag_pending.value,
            },
            {
                name:        'force freelist alloc',
                setup:       () => (
                    (uint8buffer[get_active_page() + page_flags] |= page_flag_frontier_closed),
                    alloc_pair()
                ),
                tear_down:   () => init_page(1),
                action:      () => uint32buffer[(get_active_page() + page_freelist_head)/4],
                expected:    get_active_page() + page_freelist_bottom + offset_size,
            },
            {
                name:        'force next page activation -- new page',
                setup:       () => (
                    (uint8buffer[get_active_page() + page_flags] |= page_flag_frontier_closed),
                    uint8buffer.fill(0xff, get_active_page() + page_pair_flags_area, get_active_page() + page_initial_bottom),
                    alloc_pair()
                ),
                tear_down:   () => (
                    init_page(1),
                    (uint8buffer = new Uint8Array(memory.buffer)),
                    (uint16buffer = new Uint16Array(memory.buffer)),
                    (uint32buffer = new Uint32Array(memory.buffer)),
                    (uint16buffer[memory_active_page/2] = 1)
                ),
                action:      () => get_active_page(),
                expected:    2 * page_size,
            },
            {
                name:        'force next page activation -- existing page',
                setup:       () => (
                    (uint8buffer[get_active_page() + page_flags] = page_flag_frontier_closed),
                    uint8buffer.fill(0xff, get_active_page() + page_pair_flags_area, get_active_page() + page_initial_bottom - 1),
                    (uint8buffer[get_active_page() + page_initial_bottom - 1] = 0x3f),
                    alloc_pair(),
                    alloc_pair()
                ),
                tear_down:   () => (
                    init_page(1),
                    (uint8buffer = new Uint8Array(memory.buffer)),
                    (uint16buffer = new Uint16Array(memory.buffer)),
                    (uint32buffer = new Uint32Array(memory.buffer)),
                    (uint16buffer[memory_active_page/2] = 1)
                ),
                action:      () => get_active_page(),
                expected:    2 * page_size,
            },
        ],
    },
    {
        name: 'make pair',
        enable: true,
        cases: [
            {
                name:        'make_pair flags',
                tear_down:   () => init_page(1),
                action:      () => get_pair_flags(make_pair(NULL, NULL)),
                expected:    pair_flag_pending.value,
            },
            {
                name:        'make_pair',
                tear_down:   () => init_page(1),
                action:      () => value_tag(make_pair(TRUE, FALSE)),
                expected:    tag_pair.value,
            },
            {
                name:        'car',
                tear_down:   () => init_page(1),
                action:      () => car(make_pair(TRUE, FALSE)),
                expected:    TRUE.value,
            },
            {
                name:        'cdr',
                tear_down:   () => init_page(1),
                action:      () => cdr(make_pair(TRUE, FALSE)),
                expected:    FALSE.value,
            },
        ]
    },
    {
        name: 'get group ready pair map',
        enable: true,
        cases: [
            {
                name:        'empty',
                action:      () => get_group_ready_pair_map(0n),
                expected:    0n,
            },
            {
                name:        'all pending and reachable',
                action:      () => get_group_ready_pair_map(0xffffffffffffffffn),
                expected:    0x5555555555555555n,
            },
            {
                name:        'all reachable',
                action:      () => get_group_ready_pair_map(0x5555555555555555n),
                expected:    0n,
            },
            {
                name:        'all pending',
                action:      () => get_group_ready_pair_map(0xaaaaaaaaaaaaaaaan),
                expected:    0n,
            },
            {
                name:        'all pending but least ready',
                action:      () => get_group_ready_pair_map(0xaaaaaaaaaaaaaaabn),
                expected:    1n,
            },
            {
                name:        'all pending but greatest ready',
                action:      () => get_group_ready_pair_map(0xeaaaaaaaaaaaaaaan),
                expected:    1n << 62n,
            },
        ],
    },
    {
        name: 'get ready map trace depth',
        enable: true,
        cases: [
            {
                name:        'empty',
                action:      () => get_ready_map_trace_depth(0n),
                expected:    6,
            },
            {
                name:        'lowest set',
                action:      () => get_ready_map_trace_depth(1n),
                expected:    5,
            },
            {
                name:        'highest set',
                action:      () => get_ready_map_trace_depth(1n << 62n),
                expected:    5,
            },
            {
                name:        'two set',
                action:      () => get_ready_map_trace_depth(5n),
                expected:    4,
            },
            {
                name:        'three set',
                action:      () => get_ready_map_trace_depth((1n << 62n) + 5n),
                expected:    4,
            },
            {
                name:        'four set',
                action:      () => get_ready_map_trace_depth((1n << 62n) + 21n),
                expected:    3,
            },
            {
                name:        'seven set',
                action:      () => get_ready_map_trace_depth(0x1555n),
                expected:    3,
            },
            {
                name:        'eigth set',
                action:      () => get_ready_map_trace_depth(0x5555n),
                expected:    2,
            },
            {
                name:        '15 set',
                action:      () => get_ready_map_trace_depth(0x55555551n),
                expected:    2,
            },
            {
                name:        '16 set',
                action:      () => get_ready_map_trace_depth(0x55555555n),
                expected:    1,
            },
            {
                name:        '31 set',
                action:      () => get_ready_map_trace_depth(0x1555555555555555n),
                expected:    1,
            },
            {
                name:        '32 set',
                action:      () => get_ready_map_trace_depth(0x5555555555555555n),
                expected:    0,
            },
        ],
    },
]

function is_equiv(a, b) {
    try {
        return JSON.stringify(a) == JSON.stringify(b);
    } catch {
        // BigInts end up here
        return a == b;
    }
}

function run_tests() {

    for (let i in test_units) {

        let { enable, type, name: unit_name, setup: unit_setup, tear_down: unit_tear_down, cases } = test_units[i];

        if (unit_setup) unit_setup();

        if (enable == false) continue;

        // console.log(unit_name);

        for (let j in cases) {

            let { name: case_name, setup, tear_down, action, expected } = cases[j];

            if (setup) setup();

            let actual = action();

            if (tear_down) tear_down();

            if (!is_equiv(expected, actual)) {
                console.log(`test unit '${unit_name}' case '${case_name}': expected ${expected}, actual ${actual}.`);
            }
        }

        if (unit_tear_down) unit_tear_down();

    }

}

run_tests()
