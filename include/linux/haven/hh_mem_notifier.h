/* SPDX-License-Identifier: GPL-2.0-only */
/*
 * Haven memory notifier compatibility for drivers built against Gunyah 5.10.
 */

#ifndef __HH_MEM_NOTIFIER_H
#define __HH_MEM_NOTIFIER_H

#include <linux/gunyah/gh_mem_notifier.h>

#define hh_mem_notifier_tag		gh_mem_notifier_tag
#define HH_MEM_NOTIFIER_TAG_DISPLAY	GH_MEM_NOTIFIER_TAG_DISPLAY
#define HH_MEM_NOTIFIER_TAG_TOUCH_PRIMARY \
					GH_MEM_NOTIFIER_TAG_TOUCH_PRIMARY
#define HH_MEM_NOTIFIER_TAG_TOUCH_SECONDARY \
					GH_MEM_NOTIFIER_TAG_TOUCH_SECONDARY
#define HH_MEM_NOTIFIER_TAG_TLMM	GH_MEM_NOTIFIER_TAG_TLMM
#define HH_MEM_NOTIFIER_TAG_TEST_TLMM	GH_MEM_NOTIFIER_TAG_TEST_TLMM
#define HH_MEM_NOTIFIER_TAG_TEST_TUIVM	GH_MEM_NOTIFIER_TAG_TEST_TUIVM
#define HH_MEM_NOTIFIER_TAG_TEST_OEMVM	GH_MEM_NOTIFIER_TAG_TEST_OEMVM
#define HH_MEM_NOTIFIER_TAG_MAX		GH_MEM_NOTIFIER_TAG_MAX

#define hh_mem_notifier_handler		gh_mem_notifier_handler
#define hh_mem_notifier_register	gh_mem_notifier_register
#define hh_mem_notifier_unregister	gh_mem_notifier_unregister

#endif /* __HH_MEM_NOTIFIER_H */
