From: Jack Steiner <steiner@sgi.com>
Date: Wed, 06 Jun 2001 15:21:30 +0000
Subject: [Linux-ia64] oops in proc_delete_inode
Message-Id: <marc-linux-ia64-105590693005690@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Has anyone seen this failure?

We recently upgraded to 2.4.5 and have seen this panic 
twice on different systems. Both panics occured in "top".
If we dont run top, the system stays up fine. 
I suspect a generics locking/race condition with multiple
cpus, but that is just a guess at this point. I can dig
deeper if no one else has seen the problem.



These failures occurred running on an SMP SGI platform. We have
a number of local mods that cant be ruled out as the source 
of the problem. However, we never saw this failure on 2.4.2.



Unable to handle kernel paging request at virtual address 000000000000003c
top[27526]: Oops 8821862825984

[2]kdb> bt
0xe0000000047b44d0 kdba_main_loop+0xb0
0xe000000004620a80 kdb+0xee0
0xe00000000442f310 die_if_kernel+0x130
0xe00000000444c380 ia64_do_page_fault+0x7c0
0xe000000004415a00 ia64_leave_kernel
0xe000000004563100 proc_delete_inode+0xa0	< referenced garbage address
0xe000000004554e20 iput+0x280
0xe000000004566830 proc_pid_make_inode+0x670
0xe000000004566f30 proc_base_lookup+0x150
0xe000000004536bc0 real_lookup+0x1a0
0xe0000000045383c0 path_walk+0x1220
0xe000000004539df0 open_namei+0xd0
0xe000000004517800 filp_open+0x60
0xe000000004518140 sys_open+0xa0
0xe0000000044159e0 ia64_ret_from_syscall

Failing code:

	0xe000000004563100 proc_delete_inode+0xa0 [MMI]       fetchadd4.rel r14=[r16],-1^M^M^M
	0xe000000004563106 proc_delete_inode+0xa6             ld8 r15=[r15]^M^M^M
	0xe00000000456310c proc_delete_inode+0xac             nop.i 0x0;;^M^M^M


In the following code, the inode looks reasonable. However, inode->u.generic_ip doesnt point 
to a valid proc_dir_entry. It points to a task_struct that is in "zombie" state. 
The value of de->owner is 0x3c (hence the panic).

static void proc_delete_inode(struct inode *inode)
{
        struct proc_dir_entry *de = inode->u.generic_ip;

        inode->i_state = I_CLEAR;

        if (PROC_INODE_PROPER(inode)) {
                proc_pid_delete_inode(inode);
                return;
        }
        if (de) {
                if (de->owner)
                        __MOD_DEC_USE_COUNT(de->owner);
                de_put(de);
        }
}


-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com


