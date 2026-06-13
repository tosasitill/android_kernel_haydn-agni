/* SPDX-License-Identifier: GPL-2.0-only */
/*
 * Compatibility wrappers for downstream drivers that still include the
 * pre-5.10 Haven RM headers. 5.10 exposes the same interfaces through the
 * Gunyah names.
 */

#ifndef __HH_RM_DRV_H
#define __HH_RM_DRV_H

#include <linux/bitops.h>
#include <linux/gunyah/gh_rm_drv.h>

#define hh_vmid_t			gh_vmid_t
#define hh_rm_msgid_t			gh_rm_msgid_t
#define hh_virq_handle_t		gh_virq_handle_t
#define hh_label_t			gh_label_t
#define hh_memparcel_handle_t		gh_memparcel_handle_t
#define hh_capid_t			gh_capid_t

#define hh_vm_names			gh_vm_names
#define HH_SELF_VM			GH_SELF_VM
#define HH_PRIMARY_VM			GH_PRIMARY_VM
#define HH_TRUSTED_VM			GH_TRUSTED_VM
#define HH_CPUSYS_VM			GH_CPUSYS_VM
#define HH_OEM_VM			GH_OEM_VM
#define HH_VM_MAX			GH_VM_MAX

#define hh_rm_notif_mem_shared_payload	gh_rm_notif_mem_shared_payload
#define hh_rm_notif_mem_released_payload gh_rm_notif_mem_released_payload
#define hh_rm_notif_mem_accepted_payload gh_rm_notif_mem_accepted_payload
#define hh_acl_entry			gh_acl_entry
#define hh_sgl_entry			gh_sgl_entry
#define hh_mem_attr_entry		gh_mem_attr_entry
#define hh_acl_desc			gh_acl_desc
#define hh_sgl_desc			gh_sgl_desc
#define hh_mem_attr_desc		gh_mem_attr_desc
#define hh_notify_vmid_entry		gh_notify_vmid_entry
#define hh_notify_vmid_desc		gh_notify_vmid_desc
#define hh_vm_status			gh_vm_status

#define HH_RM_NOTIF_MEM_SHARED		GH_RM_NOTIF_MEM_SHARED
#define HH_RM_NOTIF_MEM_RELEASED	GH_RM_NOTIF_MEM_RELEASED
#define HH_RM_NOTIF_MEM_ACCEPTED	GH_RM_NOTIF_MEM_ACCEPTED

#define HH_RM_MEM_TYPE_NORMAL		GH_RM_MEM_TYPE_NORMAL
#define HH_RM_MEM_TYPE_IO		GH_RM_MEM_TYPE_IO

#define HH_RM_TRANS_TYPE_DONATE		GH_RM_TRANS_TYPE_DONATE
#define HH_RM_TRANS_TYPE_LEND		GH_RM_TRANS_TYPE_LEND
#define HH_RM_TRANS_TYPE_SHARE		GH_RM_TRANS_TYPE_SHARE

#define HH_RM_ACL_X			GH_RM_ACL_X
#define HH_RM_ACL_W			GH_RM_ACL_W
#define HH_RM_ACL_R			GH_RM_ACL_R

#define HH_RM_MEM_RELEASE_CLEAR		GH_RM_MEM_RELEASE_CLEAR
#define HH_RM_MEM_RECLAIM_CLEAR		GH_RM_MEM_RECLAIM_CLEAR

#define HH_RM_MEM_ACCEPT_VALIDATE_SANITIZED \
					GH_RM_MEM_ACCEPT_VALIDATE_SANITIZED
#define HH_RM_MEM_ACCEPT_VALIDATE_ACL_ATTRS \
					GH_RM_MEM_ACCEPT_VALIDATE_ACL_ATTRS
#define HH_RM_MEM_ACCEPT_VALIDATE_LABEL	GH_RM_MEM_ACCEPT_VALIDATE_LABEL
#define HH_RM_MEM_ACCEPT_MAP_IPA_CONTIGUOUS \
					GH_RM_MEM_ACCEPT_MAP_IPA_CONTIGUOUS
#define HH_RM_MEM_ACCEPT_DONE		GH_RM_MEM_ACCEPT_DONE

#define HH_RM_MEM_SHARE_SANITIZE	GH_RM_MEM_SHARE_SANITIZE
#define HH_RM_MEM_LEND_SANITIZE		GH_RM_MEM_LEND_SANITIZE
#define HH_RM_MEM_DONATE_SANITIZE	GH_RM_MEM_DONATE_SANITIZE

#define HH_RM_MEM_NOTIFY_RECIPIENT_SHARED \
					GH_RM_MEM_NOTIFY_RECIPIENT_SHARED
#define HH_RM_MEM_NOTIFY_RECIPIENT	GH_RM_MEM_NOTIFY_RECIPIENT
#define HH_RM_MEM_NOTIFY_OWNER_RELEASED	GH_RM_MEM_NOTIFY_OWNER_RELEASED
#define HH_RM_MEM_NOTIFY_OWNER		GH_RM_MEM_NOTIFY_OWNER
#define HH_RM_MEM_NOTIFY_OWNER_ACCEPTED	GH_RM_MEM_NOTIFY_OWNER_ACCEPTED

#define HH_RM_NOTIF_VM_EXITED		GH_RM_NOTIF_VM_EXITED
#define HH_RM_NOTIF_VM_SHUTDOWN		GH_RM_NOTIF_VM_SHUTDOWN
#define HH_RM_NOTIF_VM_STATUS		GH_RM_NOTIF_VM_STATUS
#define HH_RM_NOTIF_VM_IRQ_LENT		GH_RM_NOTIF_VM_IRQ_LENT
#define HH_RM_NOTIF_VM_IRQ_RELEASED	GH_RM_NOTIF_VM_IRQ_RELEASED
#define HH_RM_NOTIF_VM_IRQ_ACCEPTED	GH_RM_NOTIF_VM_IRQ_ACCEPTED

#define hh_rm_get_vmid			gh_rm_get_vmid
#define hh_rm_mem_accept		gh_rm_mem_accept
#define hh_rm_mem_lend			gh_rm_mem_lend
#define hh_rm_mem_notify		gh_rm_mem_notify
#define hh_rm_mem_reclaim		gh_rm_mem_reclaim
#define hh_rm_mem_release		gh_rm_mem_release

#endif /* __HH_RM_DRV_H */
