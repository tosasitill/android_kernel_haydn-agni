/* SPDX-License-Identifier: GPL-2.0-only */
/*
 * Haven IRQ lending compatibility for drivers built against Gunyah 5.10.
 */

#ifndef __HH_IRQ_LEND_H
#define __HH_IRQ_LEND_H

#include <linux/gunyah/gh_irq_lend.h>

#define hh_irq_label			gh_irq_label
#define HH_IRQ_LABEL_SDE		GH_IRQ_LABEL_SDE
#define HH_IRQ_LABEL_TRUSTED_TOUCH_PRIMARY \
					GH_IRQ_LABEL_TRUSTED_TOUCH_PRIMARY
#define HH_IRQ_LABEL_TRUSTED_TOUCH_SECONDARY \
					GH_IRQ_LABEL_TRUSTED_TOUCH_SECONDARY
#define HH_IRQ_LABEL_TEST_TUIVM		GH_IRQ_LABEL_TEST_TUIVM
#define HH_IRQ_LABEL_TEST_TESTVM	GH_IRQ_LABEL_TEST_TESTVM
#define HH_IRQ_LABEL_MAX		GH_IRQ_LABEL_MAX

#define hh_irq_handle_fn		gh_irq_handle_fn
#define hh_irq_handle_fn_v2		gh_irq_handle_fn_v2

#define hh_irq_lend			gh_irq_lend
#define hh_irq_lend_v2			gh_irq_lend_v2
#define hh_irq_lend_notify		gh_irq_lend_notify
#define hh_irq_reclaim			gh_irq_reclaim
#define hh_irq_wait_for_lend		gh_irq_wait_for_lend
#define hh_irq_wait_for_lend_v2		gh_irq_wait_for_lend_v2
#define hh_irq_accept			gh_irq_accept
#define hh_irq_accept_notify		gh_irq_accept_notify
#define hh_irq_release			gh_irq_release
#define hh_irq_release_notify		gh_irq_release_notify

#endif /* __HH_IRQ_LEND_H */
