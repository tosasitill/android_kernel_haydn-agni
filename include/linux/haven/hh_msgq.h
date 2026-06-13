/* SPDX-License-Identifier: GPL-2.0-only */
/*
 * Haven message queue compatibility for drivers built against Gunyah 5.10.
 */

#ifndef __HH_MSGQ_H
#define __HH_MSGQ_H

#include <linux/gunyah/gh_msgq.h>

#define hh_msgq_label			gh_msgq_label
#define HH_MSGQ_LABEL_RM		GH_MSGQ_LABEL_RM
#define HH_MSGQ_LABEL_MEMBUF		GH_MSGQ_LABEL_MEMBUF
#define HH_MSGQ_LABEL_DISPLAY		GH_MSGQ_LABEL_DISPLAY
#define HH_MSGQ_LABEL_VSOCK		GH_MSGQ_LABEL_VSOCK
#define HH_MSGQ_LABEL_MAX		GH_MSGQ_LABEL_MAX

#define HH_MSGQ_MAX_MSG_SIZE_BYTES	GH_MSGQ_MAX_MSG_SIZE_BYTES
#define HH_MSGQ_DIRECTION_TX		GH_MSGQ_DIRECTION_TX
#define HH_MSGQ_DIRECTION_RX		GH_MSGQ_DIRECTION_RX
#define HH_MSGQ_TX_PUSH			GH_MSGQ_TX_PUSH
#define HH_MSGQ_NONBLOCK		GH_MSGQ_NONBLOCK

#define hh_msgq_register		gh_msgq_register
#define hh_msgq_unregister		gh_msgq_unregister
#define hh_msgq_send			gh_msgq_send
#define hh_msgq_recv			gh_msgq_recv
#define hh_msgq_populate_cap_info	gh_msgq_populate_cap_info
#define hh_msgq_probe			gh_msgq_probe
#define hh_msgq_reset_cap_info		gh_msgq_reset_cap_info

#endif /* __HH_MSGQ_H */
