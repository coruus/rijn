#ifndef _AESCTR_H
#define _AESCTR_H
#include <stdint.h>

/*% for name, save_schedule in [('_ks', True), ('', False)] */
/*% for N in range(1, 9) */
/*% if not save_schedule */
void aes256_ctr`N`(void* out, const void* in, uint64_t oplen, const void* key, const void* nc);
/*% else */
void aes256_ctr`N`_ks(void* out, const void* in, uint64_t oplen, const void* key, const void* nc, void* ks);
/*% endif */
/*% endfor */
/*% endfor */
#endif
