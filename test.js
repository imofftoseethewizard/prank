const fs = require("fs");

const memory_mod = new WebAssembly.Module(fs.readFileSync("memory.wasm"));
const Memory = new WebAssembly.Instance(memory_mod, {});

const algorithms_mod = new WebAssembly.Module(fs.readFileSync("algorithms.wasm"));
const Algorithms = new WebAssembly.Instance(algorithms_mod, { 'memory': Memory.exports });

const lex_mod = new WebAssembly.Module(fs.readFileSync("lex.wasm"));
const Lex = new WebAssembly.Instance(lex_mod, { 'memory': Memory.exports });

const kernel_mod = new WebAssembly.Module(fs.readFileSync("kernel.wasm"));
const Kernel = new WebAssembly.Instance(
    kernel_mod,
    {
        'algorithms': Algorithms.exports,
        'lex': Lex.exports,
        'memory': Memory.exports,
    });

const memory                                = Kernel.exports['memory'];
const offset_size                           = Kernel.exports['offset-size'];
const value_size                            = Kernel.exports['value-size'];
const pair_size                             = Kernel.exports['pair-size'];
const group_size                            = Kernel.exports['group-size'];
const page_size                             = Kernel.exports['page-size'];
const offset_size_bits                      = Kernel.exports['offset-size-bits'];
const value_size_bits                       = Kernel.exports['value-size-bits'];
const pair_size_bits                        = Kernel.exports['pair-size-bits'];
const group_size_bits                       = Kernel.exports['group-size-bits'];
const page_size_bits                        = Kernel.exports['page-size-bits'];
const memory_page_count                     = Kernel.exports['memory-page-count'];
const memory_active_page                    = Kernel.exports['memory-active-page'];
const memory_block_store                    = Kernel.exports['memory-block-store'];
const page_flags                            = Kernel.exports['page-flags'];
const page_free_count                       = Kernel.exports['page-free-count'];
const page_free_scan_current_group          = Kernel.exports['page-free-scan-current-group'];
const page_pair_bottom                      = Kernel.exports['page-pair-bottom'];
const page_next_free_pair                   = Kernel.exports['page-next-free-pair'];
const page_smudge_flags                     = Kernel.exports['page-smudge-flags'];
const page_freelist_head                    = Kernel.exports['page-freelist-head'];
const page_freelist_bottom                  = Kernel.exports['page-freelist-bottom'];
const page_freelist_top                     = Kernel.exports['page-freelist-top'];
const page_flag_frontier_closed             = Kernel.exports['page-flag-frontier-closed'];
const page_pair_flags_area                  = Kernel.exports['page-pair-flags-area'];
const page_pair_flags_byte_length           = Kernel.exports['page-pair-flags-byte-length'];
const page_initial_bottom                   = Kernel.exports['page-initial-bottom'];
const page_free_scan_end_group              = Kernel.exports['page-free-scan-end-group'];
const page_initial_free_count               = Kernel.exports['page-initial-free-count'];
const page_offset_mask                      = Kernel.exports['page-offset-mask'];
const pair_flag_reachable                   = Kernel.exports['pair-flag-reachable'];
const pair_flag_pending                     = Kernel.exports['pair-flag-pending'];
const pair_flags_mask                       = Kernel.exports['pair-flags-mask'];
const pair_smudge_shift                     = Kernel.exports['pair-smudge-shift'];
const smudge_flag_shift_mask                = Kernel.exports['smudge-flag-shift-mask'];
const max_trace_depth                       = Kernel.exports['max-trace-depth'];
const pair_flag_reachable_i64_group         = Kernel.exports['pair-flag-reachable-i64-group'];
const pair_page_offset_mask                 = Kernel.exports['pair-page-offset-mask'];
const pair_flag_addr_shift                  = Kernel.exports['pair-flag-addr-shift'];
const pair_flag_idx_mask                    = Kernel.exports['pair-flag-idx-mask'];
const pair_flag_idx_shift                   = Kernel.exports['pair-flag-idx-shift'];
const tag_mask                              = Kernel.exports['tag-mask'];
const tag_small_integer                     = Kernel.exports['tag-small-integer'];
const tag_block                             = Kernel.exports['tag-block'];
const tag_box                               = Kernel.exports['tag-box'];
const tag_char                              = Kernel.exports['tag-char'];
const tag_pair                              = Kernel.exports['tag-pair'];
const tag_procedure                         = Kernel.exports['tag-procedure'];
const tag_symbol                            = Kernel.exports['tag-symbol'];
const tag_singleton                         = Kernel.exports['tag-singleton'];
const EOF_OBJECT                            = Kernel.exports['#eof-object'];
const FALSE                                 = Kernel.exports['#false'];
const NULL                                  = Kernel.exports['#null'];
const TRUE                                  = Kernel.exports['#true'];
const blockvalue_type                       = Kernel.exports['blockvalue-type'];
const blockvalue_block                      = Kernel.exports['blockvalue-block'];
const set_blockvalue_block                  = Kernel.exports['set-blockvalue-block'];
const get_blockstore                        = Kernel.exports['get-blockstore'];
const set_blockstore                        = Kernel.exports['set-blockstore'];
const get_active_page                       = Kernel.exports['get-active-page'];
const activate_next_page                    = Kernel.exports['activate-next-page'];
const value_tag                             = Kernel.exports['value-tag'];
const pair_page_base                        = Kernel.exports['pair-page-base'];
const pair_page_offset                      = Kernel.exports['pair-page-offset'];
const get_pair_flags_location               = Kernel.exports['get-pair-flags-location'];
const get_pair_flags                        = Kernel.exports['get-pair-flags'];
const set_all_pair_flags                    = Kernel.exports['set-all-pair-flags'];
const set_pair_flag                         = Kernel.exports['set-pair-flag'];
const clear_pair_flag                       = Kernel.exports['clear-pair-flag'];
const mark_pair_reachable                   = Kernel.exports['mark-pair-reachable'];
const mark_pair_dirty                       = Kernel.exports['mark-pair-dirty'];
const mark_pair_scanned                     = Kernel.exports['mark-pair-scanned'];
const pair_smudge_flag_addr                 = Kernel.exports['pair-smudge-flag-addr'];
const pair_smudge_flag_shift                = Kernel.exports['pair-smudge-flag-shift'];
const set_group_smudge                      = Kernel.exports['set-group-smudge'];
const clear_group_smudge                    = Kernel.exports['clear-group-smudge'];
const mark_block_reachable                  = Kernel.exports['mark-block-reachable'];
const trace_value                           = Kernel.exports['trace-value'];
const trace_pair                            = Kernel.exports['trace-pair'];
const get_group_ready_pair_map              = Kernel.exports['get-group-ready-pair-map'];
const get_group_free_pair_map               = Kernel.exports['get-group-free-pair-map'];
const get_flag_group_pair_offset            = Kernel.exports['get-flag-group-pair-offset'];
const next_pair_offset                      = Kernel.exports['next-pair-offset'];
const get_ready_map_trace_depth             = Kernel.exports['get-ready-map-trace-depth'];
const trace_group                           = Kernel.exports['trace-group'];
const collection_step                       = Kernel.exports['collection-step'];
const begin_collection                      = Kernel.exports['begin-collection'];
const is_collection_complete                = Kernel.exports['collection-complete?'];
const end_collection                        = Kernel.exports['end-collection'];
const page_decr_free_count                  = Kernel.exports['page-decr-free-count'];
const fill_page_freelist_from_free_pair_map = Kernel.exports['fill-page-freelist-from-free-pair-map'];
const fill_page_freelist                    = Kernel.exports['fill-page-freelist'];
const page_alloc_freelist_pair              = Kernel.exports['page-alloc-freelist-pair'];
const is_page_frontier_closed               = Kernel.exports['page-frontier-closed?'];
const close_page_frontier                   = Kernel.exports['close-page-frontier'];
const page_alloc_frontier_pair              = Kernel.exports['page-alloc-frontier-pair'];
const alloc_pair                            = Kernel.exports['alloc-pair'];
const make_pair                             = Kernel.exports['make-pair'];
const car                                   = Kernel.exports['car'];
const cdr                                   = Kernel.exports['cdr'];
const init_block_list                       = Kernel.exports['init-block-list'];
const init_page                             = Kernel.exports['init-page'];
const blockstore_page_count                 = Kernel.exports['blockstore-page-count'];
const blockstore_block_count                = Kernel.exports['blockstore-block-count'];
const blockstore_relocation_offset          = Kernel.exports['blockstore-relocation-offset'];
const blockstore_relocation_block           = Kernel.exports['blockstore-relocation-block'];
const blockstore_current_relocation         = Kernel.exports['blockstore-current-relocation'];
const blockstore_free_area                  = Kernel.exports['blockstore-free-area'];
const block_owner                           = Kernel.exports['block-owner'];
const block_length                          = Kernel.exports['block-length'];
const free_block_next_block                 = Kernel.exports['free-block-next-block'];
const block_header_length                   = Kernel.exports['block-header-length'];
const block_header_size                     = Kernel.exports['block-header-size'];
const blockstore_header_size                = Kernel.exports['blockstore-header-size'];
const get_blockstore_page_count             = Kernel.exports['get-blockstore-page-count'];
const get_blockstore_block_count            = Kernel.exports['get-blockstore-block-count'];
const get_blockstore_freelist               = Kernel.exports['get-blockstore-freelist'];
const get_blockstore_relocation_offset      = Kernel.exports['get-blockstore-relocation-offset'];
const get_blockstore_relocation_block       = Kernel.exports['get-blockstore-relocation-block'];
const get_blockstore_current_relocation     = Kernel.exports['get-blockstore-current-relocation'];
const get_blockstore_free_area              = Kernel.exports['get-blockstore-free-area'];
const set_blockstore_page_count             = Kernel.exports['set-blockstore-page-count'];
const set_blockstore_block_count            = Kernel.exports['set-blockstore-block-count'];
const set_blockstore_relocation_offset      = Kernel.exports['set-blockstore-relocation-offset'];
const set_blockstore_relocation_block       = Kernel.exports['set-blockstore-relocation-block'];
const set_blockstore_current_relocation     = Kernel.exports['set-blockstore-current-relocation'];
const set_blockstore_free_area              = Kernel.exports['set-blockstore-free-area'];
const get_block_owner                       = Kernel.exports['get-block-owner'];
const get_block_length                      = Kernel.exports['get-block-length'];
const get_next_free_block                   = Kernel.exports['get-next-free-block'];
const set_block_owner                       = Kernel.exports['set-block-owner'];
const set_block_length                      = Kernel.exports['set-block-length'];
const set_next_free_block                   = Kernel.exports['set-next-free-block'];
const get_block_size                        = Kernel.exports['get-block-size'];
const get_next_block                        = Kernel.exports['get-next-block'];
const is_free_block                         = Kernel.exports['is-free-block'];
const is_last_free_block                    = Kernel.exports['is-last-free-block'];
const get_blockstore_initial_block          = Kernel.exports['get-blockstore-initial-block'];
const get_blockstore_top                    = Kernel.exports['get-blockstore-top'];
const is_blockstore_freelist_empty          = Kernel.exports['is-blockstore-freelist-empty'];
const is_blockstore_relocating              = Kernel.exports['is-blockstore-relocating'];
const decr_blockstore_block_count           = Kernel.exports['decr-blockstore-block-count'];
const incr_blockstore_block_count           = Kernel.exports['incr-blockstore-block-count'];
const make_free_block                       = Kernel.exports['make-free-block'];
const init_blockstore                       = Kernel.exports['init-blockstore'];
const can_split_free_block                  = Kernel.exports['can-split-free-block'];
const split_free_block                      = Kernel.exports['split-free-block'];
const alloc_exact_freelist_block            = Kernel.exports['alloc-exact-freelist-block'];
const alloc_split_freelist_block            = Kernel.exports['alloc-split-freelist-block'];
const calc_block_size                       = Kernel.exports['calc-block-size'];
const ensure_blockstore_alloc_top           = Kernel.exports['ensure-blockstore-alloc-top'];
const alloc_end_block                       = Kernel.exports['alloc-end-block'];
const alloc_block                           = Kernel.exports['alloc-block'];
const add_free_block                        = Kernel.exports['add-free-block'];
const compact_block_freelist                = Kernel.exports['compact-block-freelist'];
const dealloc_block                         = Kernel.exports['dealloc-block'];
const step_blockstore_compact               = Kernel.exports['step-blockstore-compact'];
const fill_relocation_block                 = Kernel.exports['fill-relocation-block'];
const make_relocation_block                 = Kernel.exports['make-relocation-block'];
const begin_relocate_blockstore             = Kernel.exports['begin-relocate-blockstore'];
const step_relocate_blockstore              = Kernel.exports['step-relocate-blockstore'];
const end_relocate_blockstore               = Kernel.exports['end-relocate-blockstore'];

var uint8buffer = new Uint8Array(memory.buffer);
var uint16buffer = new Uint16Array(memory.buffer);
var uint32buffer = new Uint32Array(memory.buffer);

test_units = [
    {
        name: 'memory init',
        enable: false,
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
        enable: false,
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
        enable: false,
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
        enable: false,
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
        enable: false,
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
        enable: false,
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
        enable: false,
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
        enable: false,
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
        enable: false,
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
        enable: false,
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
        ]
    },
    {
        name: 'getters, setters, and utility fns',
        enable: true,
        cases: [
            {
                name:        'get/set blockstore',
                setup:       () => set_blockstore(10),
                action:      () => get_blockstore(),
                expected:    10,
            },
            {
                name:        'get blockstore freelist',
                setup:       () => set_blockstore(0x50000),
                action:      () => get_blockstore_freelist(0x50000),
                expected:    0x50000 + blockstore_header_size,
            },
            {
                name:        'make free block -- owner',
                setup:       () => make_free_block(0x50000, 1, NULL),
                action:      () => get_block_owner(0x50000),
                expected:    NULL.value,
            },
            {
                name:        'make free block -- owner',
                setup:       () => make_free_block(0x50000, 7, NULL),
                action:      () => get_block_length(0x50000),
                expected:    7,
            },
            {
                name:        'make free block -- next free block',
                setup:       () => make_free_block(0x50000, 7, NULL),
                action:      () => get_next_free_block(0x50000),
                expected:    NULL.value,
            },
            {
                name:        'make free block -- next free block',
                setup:       () => make_free_block(0x50000, 7, 0x5010),
                action:      () => get_next_free_block(0x50000),
                expected:    0x5010,
            },
        ]
    },
    {
        name: 'init block store',
        enable: true,
        cases: [
            {
                name:        'simple',
                setup:       () => init_blockstore(5, 1),
                action:      () => get_blockstore(),
                expected:    5 * page_size,
            },
            {
                name:        'page count',
                setup:       () => init_blockstore(5, 1),
                action:      () => get_blockstore_page_count(),
                expected:    1,
            },
            {
                name:        'block count',
                setup:       () => init_blockstore(5, 1),
                action:      () => get_blockstore_block_count(),
                expected:    1,
            },
            {
                name:        'relocation offset',
                setup:       () => init_blockstore(5, 1),
                action:      () => get_blockstore_relocation_offset(),
                expected:    0,
            },
            {
                name:        'relocation block',
                setup:       () => init_blockstore(5, 1),
                action:      () => get_blockstore_relocation_block(),
                expected:    NULL.value,
            },
            {
                name:        'current relocation',
                setup:       () => init_blockstore(5, 1),
                action:      () => get_blockstore_current_relocation(),
                expected:    NULL.value,
            },
            {
                name:        'freelist is last free block',
                setup:       () => init_blockstore(5, 1),
                action:      () => is_last_free_block(get_blockstore_freelist()),
                expected:    1,
            },
            {
                name:        'is freelist empty',
                setup:       () => init_blockstore(5, 1),
                action:      () => is_blockstore_freelist_empty(),
                expected:    1,
            },
            {
                name:        'freelist is last free block',
                setup:       () => init_blockstore(5, 1),
                action:      () => is_last_free_block(get_blockstore_freelist()),
                expected:    1,
            },
            {
                name:        'last block is freelist',
                setup:       () => init_blockstore(5, 1),
                action:      () => get_next_block(get_blockstore_freelist()) - get_blockstore_free_area(),
                expected:    0,
            },
        ]
    },
    {
        name: 'alloc end block',
        enable: true,
        cases: [
            {
                name:        'at old end',
                setup:       () => init_blockstore(5, 1),
                action:      () => get_blockstore_free_area() - alloc_end_block(NULL, 10),
                expected:    0,
            },
            {
                name:        'free area moved',
                setup:       () => init_blockstore(5, 1),
                action:      () => (
                    get_blockstore_free_area()
                    + 0*alloc_end_block(NULL, 10)
                    - get_blockstore_free_area()
                ),
                expected:    -calc_block_size(10),
            },
            {
                name:        'new block is end block',
                setup:       () => init_blockstore(5, 1),
                action:      () => get_next_block(alloc_end_block(NULL, 10)) - get_blockstore_free_area(),
                expected:    0
            },
            {
                name:        'new block owner',
                setup:       () => init_blockstore(5, 1),
                action:      () => get_block_owner(alloc_end_block(715, 10)),
                expected:    715
            },
            {
                name:        'new block length',
                setup:       () => init_blockstore(5, 1),
                action:      () => get_block_length(alloc_end_block(715, 10)),
                expected:    10
            },
            {
                name:        'block count',
                setup:       () => init_blockstore(5, 1),
                action:      () => (
                    get_blockstore_block_count()
                    + 0*alloc_end_block(NULL, 10)
                    - get_blockstore_block_count()
                ),
                expected:    -1
            },
            {
                name:        '2 blocks -- 1st owner',
                setup:       function() {
                    init_blockstore(5, 1);
                    let a = alloc_end_block(1, 5);
                    let b = alloc_end_block(2, 7);
                },
                action:      () => get_block_owner(get_next_block(get_blockstore_initial_block())),
                expected:    1
            },
            {
                name:        '2 blocks -- 1st length',
                setup:       function() {
                    init_blockstore(5, 1);
                    let a = alloc_end_block(1, 5);
                    let b = alloc_end_block(2, 7);
                },
                action:      () => get_block_length(get_next_block(get_blockstore_initial_block())),
                expected:    5
            },
            {
                name:        '2 blocks -- 2nd owner',
                setup:       function() {
                    init_blockstore(5, 1);
                    let a = alloc_end_block(1, 5);
                    let b = alloc_end_block(2, 7);
                },
                action:      () => get_block_owner(get_next_block(get_next_block(get_blockstore_initial_block()))),
                expected:    2
            },
            {
                name:        '2 blocks -- 2nd length',
                setup:       function() {
                    init_blockstore(5, 1);
                    let a = alloc_end_block(1, 5);
                    let b = alloc_end_block(2, 7);
                },
                action:      () => get_block_length(get_next_block(get_next_block(get_blockstore_initial_block()))),
                expected:    7
            },
        ]
    },
    {
        name: 'add free list block',
        enable: true,
        cases: [
            {
                name:        'simple 1',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(NULL, 10))
                ),
                action:      () => is_last_free_block(get_blockstore_freelist()),
                expected:    0
            },
            {
                name:        'simple 2',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(NULL, 10))
                ),
                action:      () => is_last_free_block(get_next_block(get_blockstore_freelist())),
                expected:    1
            },
            {
                name:        'simple 3',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(NULL, 10))
                ),
                action:      () => is_last_free_block(get_next_free_block(get_blockstore_freelist())),
                expected:    1
            },
            {
                name:        'insert end 1',
                setup:       function() {
                    init_blockstore(5, 1);
                    let a = alloc_end_block(NULL, 5);
                    let b = alloc_end_block(NULL, 7);
                    add_free_block(a);
                    add_free_block(b);
                },
                action:      () => is_last_free_block(get_blockstore_freelist()),
                expected:    0
            },
            {
                name:        'insert end 2',
                setup:       function() {
                    init_blockstore(5, 1);
                    let a = alloc_end_block(NULL, 5);
                    let b = alloc_end_block(NULL, 7);
                    add_free_block(a);
                    add_free_block(b);
                },
                action:      () => is_last_free_block(get_next_free_block(get_blockstore_freelist())),
                expected:    0
            },
            {
                name:        'insert end 3',
                setup:       function() {
                    init_blockstore(5, 1);
                    let a = alloc_end_block(NULL, 5);
                    let b = alloc_end_block(NULL, 7);
                    add_free_block(a);
                    add_free_block(b);
                },
                action:      () => get_block_length(get_next_free_block(get_blockstore_freelist())),
                expected:    5
            },
            {
                name:        'insert end 3',
                setup:       function() {
                    init_blockstore(5, 1);
                    let a = alloc_end_block(NULL, 5);
                    let b = alloc_end_block(NULL, 7);
                    add_free_block(a);
                    add_free_block(b);
                },
                action:      () => get_block_length(get_next_free_block(get_next_free_block(get_blockstore_freelist()))),
                expected:    7
            },
            {
                name:        'insert end 4',
                setup:       function() {
                    init_blockstore(5, 1);
                    let a = alloc_end_block(NULL, 5);
                    let b = alloc_end_block(NULL, 7);
                    add_free_block(b);
                    add_free_block(a);
                },
                action:      () => is_last_free_block(get_next_free_block(get_next_free_block(get_blockstore_freelist()))),
                expected:    1
            },
            {
                name:        'insert front 1',
                setup:       function() {
                    init_blockstore(5, 1);
                    let a = alloc_end_block(NULL, 5);
                    let b = alloc_end_block(NULL, 7);
                    add_free_block(b);
                    add_free_block(a);
                },
                action:      () => is_last_free_block(get_blockstore_freelist()),
                expected:    0
            },
            {
                name:        'insert front 2',
                setup:       function() {
                    init_blockstore(5, 1);
                    let a = alloc_end_block(NULL, 5);
                    let b = alloc_end_block(NULL, 7);
                    add_free_block(b);
                    add_free_block(a);
                },
                action:      () => is_last_free_block(get_next_free_block(get_blockstore_freelist())),
                expected:    0
            },
            {
                name:        'insert front 3',
                setup:       function() {
                    init_blockstore(5, 1);
                    let a = alloc_end_block(NULL, 5);
                    let b = alloc_end_block(NULL, 7);
                    add_free_block(b);
                    add_free_block(a);
                },
                action:      () => get_block_length(get_next_free_block(get_blockstore_freelist())),
                expected:    5
            },
            {
                name:        'insert front 4',
                setup:       function() {
                    init_blockstore(5, 1);
                    let a = alloc_end_block(NULL, 5);
                    let b = alloc_end_block(NULL, 7);
                    add_free_block(b);
                    add_free_block(a);
                },
                action:      () => is_last_free_block(get_next_free_block(get_next_free_block(get_blockstore_freelist()))),
                expected:    1
            },
        ],
    },
    {
        name: 'can split free block',
        enable: true,
        cases: [
            {
                name:        'minimal block',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(NULL, 1))
                ),
                action:      () => can_split_free_block(get_next_free_block(get_blockstore_freelist()), 1),
                expected:    0,
            },
            {
                name:        'small block 2',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(NULL, 2))
                ),
                action:      () => can_split_free_block(get_next_free_block(get_blockstore_freelist()), 1),
                expected:    0,
            },
            {
                name:        'small block 3',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(NULL, 3))
                ),
                action:      () => can_split_free_block(get_next_free_block(get_blockstore_freelist()), 1),
                expected:    0,
            },
            {
                name:        'minimal splittable 3',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(NULL, 4))
                ),
                action:      () => can_split_free_block(get_next_free_block(get_blockstore_freelist()), 1),
                expected:    1,
            },
        ],
    },
    {
        name: 'split free block',
        enable: true,
        cases: [
            {
                name:        'minimal block',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(NULL, 1))
                ),
                action:      () => split_free_block(get_next_free_block(get_blockstore_freelist()), 1),
                expected:    0,
            },
            {
                name:        'small block 2',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(NULL, 2))
                ),
                action:      () => split_free_block(get_next_free_block(get_blockstore_freelist()), 1),
                expected:    0,
            },
            {
                name:        'small block 3',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(NULL, 3))
                ),
                action:      () => split_free_block(get_next_free_block(get_blockstore_freelist()), 1),
                expected:    0,
            },
            {
                name:        'minimal splittable 3',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(NULL, 4))
                ),
                action:      () => split_free_block(get_next_free_block(get_blockstore_freelist()), 1),
                expected:    1,
            },
            {
                name:        'minimal splittable 3',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(NULL, 4)),
                    split_free_block(get_next_free_block(get_blockstore_freelist()), 1)
                ),
                action:      () => get_blockstore_block_count(),
                expected:    3,
            },
            {
                name:        'split 14 -> 7/5 -- length 1',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(NULL, 14)),
                    split_free_block(get_next_free_block(get_blockstore_freelist()), 7)
                ),
                action:      () => get_block_length(get_next_block(get_blockstore_initial_block())),
                expected:    7,
            },
            {
                name:        'split 14 -> 7/5 -- length 2',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(NULL, 14)),
                    split_free_block(get_next_free_block(get_blockstore_freelist()), 7)
                ),
                action:      () => get_block_length(get_next_block(get_next_block(get_blockstore_initial_block()))),
                expected:    5,
            },
            {
                name:        'split 14 -> 7/5 -- freelist 1',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(NULL, 14)),
                    split_free_block(get_next_free_block(get_blockstore_freelist()), 7)
                ),
                action:      () => get_block_length(get_next_free_block(get_blockstore_freelist())),
                expected:    7,
            },
            {
                name:        'split 14 -> 7/5 -- freelist 1',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(NULL, 14)),
                    split_free_block(get_next_free_block(get_blockstore_freelist()), 7)
                ),
                action:      () => get_block_length(get_next_free_block(get_next_free_block(get_blockstore_freelist()))),
                expected:    5,
            },
        ],
    },
    {
        name: 'alloc exact block',
        enable: true,
        cases: [
            {
                name:        'empty',
                setup:       () => (
                    init_blockstore(5, 1)
                ),
                action:      () => alloc_exact_freelist_block(11, 1),
                expected:    NULL.value,
            },
            {
                name:        '5 in 14',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(NULL, 14))
                ),
                action:      () => alloc_exact_freelist_block(11, 5),
                expected:    NULL.value,
            },
            {
                name:        '5 in 5 success check',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(NULL, 5))
                ),
                action:      () => alloc_exact_freelist_block(11, 5) == get_next_block(get_blockstore_initial_block()),
                expected:    true,
            },
            {
                name:        '5 in 5 freelist empty',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(NULL, 5)),
                    alloc_exact_freelist_block(11, 5)
                ),
                action:      () => is_blockstore_freelist_empty(),
                expected:    1,
            },
            {
                name:        '5 in 5,7 success check',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(NULL, 5)),
                    add_free_block(alloc_end_block(NULL, 7))
                ),
                action:      () => alloc_exact_freelist_block(11, 5) == get_next_block(get_blockstore_initial_block()),
                expected:    true,
            },
            {
                name:        '5 in 5,7 freelist length 1',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(NULL, 5)),
                    add_free_block(alloc_end_block(NULL, 7)),
                    alloc_exact_freelist_block(11, 5)
                ),
                action:      () => is_last_free_block(get_next_free_block(get_blockstore_freelist())),
                expected:    1,
            },
        ],
    },
    {
        name: 'alloc freelist block (splitting)',
        enable: true,
        cases: [
            {
                name:        'empty',
                setup:       () => (
                    init_blockstore(5, 1)
                ),
                action:      () => alloc_split_freelist_block(11, 1),
                expected:    NULL.value,
            },
            {
                name:        'too small -- 1',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(NULL, 7))
                ),
                action:      () => alloc_split_freelist_block(11, 14),
                expected:    NULL.value,
            },
            {
                name:        'too small -- 2',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(NULL, 7))
                ),
                action:      () => alloc_split_freelist_block(11, 7),
                expected:    NULL.value,
            },
            {
                name:        'too small -- 3',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(NULL, 7))
                ),
                action:      () => alloc_split_freelist_block(11, 5),
                expected:    NULL.value,
            },
            {
                name:        '7 split for 4 -- basic',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(NULL, 7)),
                    alloc_split_freelist_block(11, 4)
                ),
                action:      () => get_block_length(get_next_block(get_blockstore_initial_block())),
                expected:    4,
            },
            {
                name:        '7 split for 4 -- free block length',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(NULL, 7)),
                    alloc_split_freelist_block(11, 4)
                ),
                action:      () => get_block_length(get_next_block(get_next_block(get_blockstore_initial_block()))),
                expected:    1,
            },
            {
                name:        '7 split for 4 -- freelist',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(NULL, 7)),
                    alloc_split_freelist_block(11, 4)
                ),
                action:      () => get_block_length(get_next_free_block(get_blockstore_freelist())),
                expected:    1,
            },
            {
                name:        '7 split for 4 -- block count',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(NULL, 7)),
                    alloc_split_freelist_block(11, 4)
                ),
                action:      () => get_blockstore_block_count(),
                expected:    3,
            },
        ],
    },
    {
        name: 'alloc block',
        enable: true,
        cases: [
            {
                name:        'length 0',
                setup:       () => (
                    init_blockstore(5, 1)
                ),
                action:      () => alloc_block(77, 0),
                expected:    NULL.value
            },
            {
                name:        'length 1 -- length check',
                setup:       () => (
                    init_blockstore(5, 1),
                    alloc_block(77, 1)
                ),
                action:      () => get_block_length(get_next_block(get_blockstore_initial_block())),
                expected:    1
            },
            {
                name:        'length 1 -- owner check',
                setup:       () => (
                    init_blockstore(5, 1),
                    alloc_block(77, 1)
                ),
                action:      () => get_block_owner(get_next_block(get_blockstore_initial_block())),
                expected:    77
            },
            {
                name:        '3 for 7,3 -- owner check',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(NULL, 7)),
                    add_free_block(alloc_end_block(NULL, 3)),
                    alloc_block(77, 3)
                ),
                action:      () => get_block_owner(get_next_block(get_next_block(get_blockstore_initial_block()))),
                expected:    77
            },
            {
                name:        '4 for 7,3 -- owner check',
                enable: false,
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(NULL, 7)),
                    add_free_block(alloc_end_block(NULL, 3)),
                    alloc_block(77, 4)
                ),
                action:      () => get_block_owner(get_next_block(get_blockstore_initial_block())),
                expected:    77
            },
            {
                name:        '4 for 7,3 -- block count',
                enable: false,
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(NULL, 7)),
                    add_free_block(alloc_end_block(NULL, 3)),
                    alloc_block(77, 4)
                ),
                action:      () => get_blockstore_block_count(),
                expected:    4
            },
            {
                name:        'force grow memory',
                enable: false,
                setup:       () => (
                    init_blockstore(5, 1),
                    alloc_block(77, 0x20000)
                ),
                action:      () => get_blockstore_block_count(),
                expected:    2
            },
        ],
    },
    {
        name: 'compact freelist',
        enable: true,
        cases: [
            {
                name:        'empty',
                setup:       () => (
                    init_blockstore(5, 1),
                    compact_block_freelist()
                ),
                action:      () => get_blockstore_block_count(),
                expected:    1,
            },
            {
                name:        'one alloc -- block count',
                setup:       () => (
                    init_blockstore(5, 1),
                    alloc_end_block(77, 5),
                    compact_block_freelist()
                ),
                action:      () => get_blockstore_block_count(),
                expected:    2,
            },
            {
                name:        'one alloc -- free list',
                setup:       () => (
                    init_blockstore(5, 1),
                    alloc_end_block(77, 5),
                    compact_block_freelist()
                ),
                action:      () => is_blockstore_freelist_empty(),
                expected:    1,
            },
            {
                name:        'one free -- block count',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(77, 5)),
                    compact_block_freelist()
                ),
                action:      () => get_blockstore_block_count(),
                expected:    1,
            },
            {
                name:        'one free -- free list',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(77, 5)),
                    compact_block_freelist()
                ),
                action:      () => is_blockstore_freelist_empty(),
                expected:    1,
            },
            {
                name:        'two free -- block count',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(77, 5)),
                    add_free_block(alloc_end_block(77, 5)),
                    compact_block_freelist()
                ),
                action:      () => get_blockstore_block_count(),
                expected:    1,
            },
            {
                name:        'two free -- free list',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(77, 5)),
                    add_free_block(alloc_end_block(77, 5)),
                    compact_block_freelist()
                ),
                action:      () => is_blockstore_freelist_empty(),
                expected:    1,
            },
            {
                name:        'three free -- block count',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(77, 5)),
                    add_free_block(alloc_end_block(77, 5)),
                    add_free_block(alloc_end_block(77, 5)),
                    compact_block_freelist()
                ),
                action:      () => get_blockstore_block_count(),
                expected:    1,
            },
            {
                name:        'three free -- free list',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(77, 5)),
                    add_free_block(alloc_end_block(77, 5)),
                    add_free_block(alloc_end_block(77, 5)),
                    compact_block_freelist()
                ),
                action:      () => is_blockstore_freelist_empty(),
                expected:    1,
            },
            {
                name:        'two free, one alloc-- block count',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(77, 5)),
                    add_free_block(alloc_end_block(77, 5)),
                    alloc_end_block(77, 5),
                    compact_block_freelist()
                ),
                action:      () => get_blockstore_block_count(),
                expected:    3,
            },
            {
                name:        'two free, one alloc -- free list',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(77, 5)),
                    add_free_block(alloc_end_block(77, 5)),
                    alloc_end_block(77, 5),
                    compact_block_freelist()
                ),
                action:      () => is_blockstore_freelist_empty(),
                expected:    0,
            },
            {
                name:        'two free, one alloc -- block length',
                setup:       () => (
                    init_blockstore(5, 1),
                    add_free_block(alloc_end_block(77, 5)),
                    add_free_block(alloc_end_block(77, 5)),
                    alloc_end_block(77, 5),
                    compact_block_freelist()
                ),
                action:      () => get_block_length(get_next_free_block(get_blockstore_freelist())),
                expected:    10 + block_header_length,
            },
        ],
    },
    {
        name: 'dealloc block',
        enable: true,
        cases: [
            {
                name:        'one alloc',
                setup:       () => (
                    init_blockstore(5, 1),
                    dealloc_block(alloc_end_block(77, 5))
                ),
                action:      () => get_blockstore_block_count(),
                expected:    1,
            },
            {
                name:        'one alloc',
                setup:       () => (
                    init_blockstore(5, 1),
                    dealloc_block(alloc_end_block(77, 5))
                ),
                action:      () => is_blockstore_freelist_empty(),
                expected:    1,
            },
            {
                name:        'two alloc, dealloc last',
                setup:       () => (
                    init_blockstore(5, 1),
                    alloc_end_block(77, 5),
                    dealloc_block(alloc_end_block(77, 5))
                ),
                action:      () => get_blockstore_block_count(),
                expected:    2,
            },
            {
                name:        'two alloc, dealloc last',
                setup:       () => (
                    init_blockstore(5, 1),
                    alloc_end_block(77, 5),
                    dealloc_block(alloc_end_block(77, 5))
                ),
                action:      () => is_blockstore_freelist_empty(),
                expected:    1,
            },
            {
                name:        'two alloc, dealloc first',
                setup:       function() {
                    init_blockstore(5, 1);
                    let a = alloc_end_block(77, 5);
                    alloc_end_block(77, 5);
                    dealloc_block(a);
                },
                action:      () => get_blockstore_block_count(),
                expected:    3,
            },
            {
                name:        'two alloc, dealloc first',
                setup:       function() {
                    init_blockstore(5, 1);
                    let a = alloc_end_block(77, 5);
                    alloc_end_block(77, 5);
                    dealloc_block(a);
                },
                action:      () => is_blockstore_freelist_empty(),
                expected:    0,
            },
            {
                name:        'three alloc, dealloc first, second',
                setup:       function() {
                    init_blockstore(5, 1);
                    let a = alloc_end_block(77, 5);
                    let b = alloc_end_block(77, 5);
                    let c = alloc_end_block(77, 5);
                    dealloc_block(a);
                    dealloc_block(b);
                },
                action:      () => get_blockstore_block_count(),
                expected:    3,
            },
            {
                name:        'three alloc, dealloc first, second',
                setup:       function() {
                    init_blockstore(5, 1);
                    let a = alloc_end_block(77, 5);
                    let b = alloc_end_block(77, 5);
                    let c = alloc_end_block(77, 5);
                    dealloc_block(a);
                    dealloc_block(b);
                },
                action:      () => is_blockstore_freelist_empty(),
                expected:    0,
            },
            {
                name:        'three alloc, dealloc second, third',
                setup:       function() {
                    init_blockstore(5, 1);
                    let a = alloc_end_block(77, 5);
                    let b = alloc_end_block(77, 5);
                    let c = alloc_end_block(77, 5);
                    dealloc_block(b);
                    dealloc_block(c);
                },
                action:      () => get_blockstore_block_count(),
                expected:    2,
            },
            {
                name:        'three alloc, dealloc second, third',
                setup:       function() {
                    init_blockstore(5, 1);
                    let a = alloc_end_block(77, 5);
                    let b = alloc_end_block(77, 5);
                    let c = alloc_end_block(77, 5);
                    dealloc_block(b);
                    dealloc_block(c);
                },
                action:      () => is_blockstore_freelist_empty(),
                expected:    1,
            },
        ],
    },
    {
        name: 'step blockstore compact',
        enable: true,
        cases: [
            {
                name:        'empty',
                setup:       () => (
                    init_blockstore(5, 1),
                    step_blockstore_compact()
                ),
                action:      () => get_blockstore_block_count(),
                expected:    1,
            },
            {
                name:        'one alloc',
                setup:       () => (
                    init_blockstore(5, 1),
                    alloc_end_block(77, 5),
                    step_blockstore_compact()
                ),
                action:      () => get_blockstore_block_count(),
                expected:    2,
            },
            {
                name:        'free, one alloc -- block count',
                setup:       function() {
                    init_blockstore(5, 1);
                    let a = alloc_end_block(77, 5);
                    let b = alloc_end_block(88, 5);
                    dealloc_block(a);
                    step_blockstore_compact();
                },
                action:      () => get_blockstore_block_count(),
                expected:    2,
            },
            {
                name:        'free, one alloc -- block count',
                setup:       function() {
                    init_blockstore(5, 1);
                    let a = alloc_end_block(77, 5);
                    let b = alloc_end_block(88, 5);
                    dealloc_block(a);
                    step_blockstore_compact();
                },
                action:      () => get_block_owner(get_next_block(get_blockstore_initial_block())),
                expected:    88,
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
