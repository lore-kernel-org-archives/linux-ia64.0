From: "Prickett, Terry O" <terry.o.prickett@intel.com>
Date: Thu, 03 May 2001 14:53:21 +0000
Subject: [Linux-ia64] RE: Problem with scsi/2.4.2 kernel : help
Message-Id: <marc-linux-ia64-105590693005528@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hiren,

We have observed a very similar occurrence.

When the following script is run the system "stalls" for approximately
15 minutes.  Only pings and keyboard echo's seem to work.  You cannot
log in and procinfo -n1 -D hangs.

	date
	dd if=/dev/sdb6 of=/dev/sdc3 bs24k count0 &
	dd if=/dev/sdc1 of=/dev/sdc4 bs24k count0 &
	wait
	date

The system is a 4-way PIII Xeon with 4GB memory with 3 SCSI disks
connected via a Symbios 896 controller. 
The OS is 2.4.3 with lockmeter and kernel profiler patches applied

When looking at the lockmeter data (see below) for this test there is
considerable contention for the BKL.  Looking further into fs/block_dev.c,
2 routines (blkdev_put, blkdev_open) execute a serializing semaphore
followed by BKL (pseudo code below).  It should also be noted that
blkdev_get only used the bd_sem and did not lock the kernel.

blkdev_xxx ()
	down(&bdev->bd_sem);
	lock_kernel();
	....code inserted here.
	unlock_kernel();
	up(&bdev->bd_sem);
	return;

How does this relate to the dd issue...  Well, blkdev_put calls
fsync_dev while holding the BKL,  fsync_dev in turns calls
sync_buffers.  The buffer.c code was changed to use the lru_list_lock
for synchronization and not the BKL in 2.4.  sync_buffers called
indirectly from blkdev_put causes the entire sync_buffers routine
(with wait set) to be executed while holding the BKL. The sync_buffer
routine is very expensive to call while holding the BKL when large
amounts of buffers are on the list.

From looking at the code it appeared the BKL in blkdev_put and blkdev_open
was unnecessary.  However, we are not 100% sure if this is true or of
the possible side effects of removing the locks.  

We experimented with removing the BKL from the blkdev_put and
blkdev_open routines and the dd issue went away (dd time reduced
to 30 seconds with no hang).
We have done some very limited testing with no issues or data
corruption, so far.

It appears that removing the BKL from blkdev_put and blkdev_open resolves
this
issue.  The question is: Does anyone know of a reason for the BKL in this
code?
Like I said before we have looked at the code and can find no reason,
however we
could have easily overlooked something.

What follows is excerpts of lockmeter data from running with
the original code and the code without the BKL in blkdev_put and
blkdev_open. 
I apologize for the data going over 80 columns.

Stock 2.4.3 kernel
>SPINLOCKS         HOLD            WAIT
>  UTIL  CON    MEAN(  MAX )  MEAN(  MAX )(% CPU)  TOTAL NOWAIT SPIN RJECT
NAME
>  1.4%  3.1%   17ms(5519ms) 590ms(4935ms)(0.37%)    800 96.9%  3.1%    0%
kernel_flag
> 0.00%    0%  3.3us( 5.5us)   0us                     4  100%    0%    0%
blkdev_open+0x44
> 0.73% 25.0% 1794ms(5519ms)3919us(3919us)(0.00%)      4 75.0% 25.0%    0%
blkdev_put+0x48
> 0.00%    0%  1.1us( 1.4us)   0us                     3  100%    0%    0%
chrdev_open+0x5c
> 0.00%    0%  1.2us( 1.2us)   0us                     1  100%    0%    0%
compute_creds+0x80
> 0.00%    0%  0.7us( 1.0us)   0us                     4  100%    0%    0%
de_put+0x34
> 0.00% 28.6%   54us( 129us)1934us(3300us)(0.00%)      7 71.4% 28.6%    0%
do_exit+0x100
> 0.00%    0%   10us(  13us)   0us                     4  100%    0%    0%
ext2_delete_inode+0x2c
> 0.00%    0%  1.4us( 4.5us)   0us                    11  100%    0%    0%
ext2_discard_prealloc+0x2c
> 0.00%    0%  7.4us(  75us)   0us                    40  100%    0%    0%
ext2_get_block+0x5c
> 0.00%    0%  1.7us( 4.2us)   0us                    11  100%    0%    0%
locks_remove_flock+0x40
> 0.00% 23.1%  0.4us( 1.3us) 142ms( 417ms)(0.01%)     13 76.9% 23.1%    0%
locks_remove_posix+0x40
> 0.00%    0%   40us(  89us)   0us                     5  100%    0%    0%
lookup_hash+0x9c
> 0.00%    0%  4.6us( 5.7us)   0us                     2  100%    0%    0%
posix_lock_file+0x7c
> 0.00%    0%   53us( 327us)   0us                    20  100%    0%    0%
real_lookup+0x7c
> 0.68%  1.5%   11ms( 306ms) 737ms(4935ms)(0.17%)    598 98.5%  1.5%    0%
schedule+0x488
> 0.00% 20.0%  144us( 371us)1317ms(1317ms)(0.03%)      5 80.0% 20.0%    0%
sync_old_buffers+0x28
> 0.00%    0%  2.1us( 4.7us)   0us                    11  100%    0%    0%
sys_flock+0xb8> 
> 0.00%    0%  2.7us( 6.0us)   0us                     4  100%    0%    0%
sys_ioctl+0x50
> 0.00% 35.7%  0.8us( 2.4us) 146ms( 711ms)(0.02%)     14 64.3% 35.7%    0%
sys_llseek+0x90
> 0.00%    0%  0.6us( 1.3us)   0us                    12  100%    0%    0%
sys_lseek+0x7c
> 0.00%    0%  4.0us( 4.0us)   0us                     1  100%    0%    0%
tty_read+0xb8
> 0.00% 21.4%   35us(  96us)1876ms(4906ms)(0.14%)     14 78.6% 21.4%    0%
tty_write+0x1e4
> 0.00%    0%   34us(  66us)   0us                     4  100%    0%    0%
vfs_create+0xbc
> 0.00%    0%  7.8us( 7.8us)   0us                     1  100%    0%    0%
vfs_link+0xb8
> 0.00%    0%   20us(  22us)   0us                     2  100%    0%    0%
vfs_statfs+0x5c
> 0.00% 20.0%  7.2us(  11us)7675us(7675us)(0.00%)      5 80.0% 20.0%    0%
vfs_unlink+0x124
>
> 98.6%  7.3%  864us( 358ms)  13us( 358ms)(0.03%)1126995 92.7%  7.3%    0%
lru_list_lock
> 0.10% 25.0%  250ms( 358ms) 4.0us( 4.0us)(0.00%)      4 75.0% 25.0%    0%
__invalidate_buffers+0x24
> 0.00%  5.0%  0.3us( 0.8us) 4.7us( 4.7us)(0.00%)     20 95.0%  5.0%    0%
buffer_insert_inode_queue+0x18
> 0.00% 0.22%  0.6us( 2.4us)7450us(  85ms)(0.00%)   5488 99.8% 0.22%    0%
flush_dirty_buffers+0x18
> 0.00%    0%  0.4us( 0.7us)   0us                    12  100%    0%    0%
fsync_inode_buffers+0xb8
> 0.00% 28.6%  0.2us( 0.3us)6089us(7212us)(0.00%)      7 71.4% 28.6%    0%
fsync_inode_buffers+0x140
> 0.13%  9.1%  2.6us( 154us)  15us( 358ms)(0.02%) 511825 90.9%  9.1%    0%
getblk+0x1c
> 0.00%    0%  0.2us( 0.2us)   0us                     5  100%    0%    0%
osync_inode_buffers+0x18
> 0.02%  8.6%  0.5us( 166us) 7.8us(7292us)(0.01%) 409693 91.4%  8.6%    0%
refile_buffer+0x14
> 97.7% 0.12% 4839us(  86ms) 1.8us( 9.1us)(0.00%) 199353 99.9% 0.12%    0%
sync_buffers+0x30
> 0.64%    0%   11ms(  85ms)   0us                   585  100%    0%    0%
sync_buffers+0x1ac
> 0.00%    0%  4.2us( 5.4us)   0us                     3  100%    0%    0%
try_to_free_buffers+0x38
>
> 


data with BKL removed from blkdev_put and blkdev_open 
>SPINLOCKS         HOLD            WAIT
>  UTIL  CON    MEAN(  MAX )  MEAN(  MAX )(% CPU)  TOTAL NOWAIT SPIN RJECT
NAME
>  4.1%    0%   27ms( 358ms)   0us                    44  100%    0%    0%
kernel_flag
> 0.00%    0%  3.1us( 5.4us)   0us                     4  100%    0%    0%
blkdev_open+0x44
>  4.1%    0%  292ms( 358ms)   0us                     4  100%    0%    0%
blkdev_put+0x5c
> 0.00%    0%  0.9us( 1.3us)   0us                     2  100%    0%    0%
chrdev_open+0x5c
> 0.00%    0%  1.0us( 1.0us)   0us                     1  100%    0%    0%
de_put+0x34
> 0.00%    0%   42us(  44us)   0us                     3  100%    0%    0%
do_exit+0x100
> 0.00%    0%  5.9us( 6.8us)   0us                     4  100%    0%    0%
fsync_dev+0x38
> 0.00%    0%  101us( 113us)   0us                     2  100%    0%    0%
lookup_hash+0x9c
> 0.00%    0%   92us( 209us)   0us                     5  100%    0%    0%
real_lookup+0x7c
> 0.00%    0%   40us( 220us)   0us                     6  100%    0%    0%
sync_old_buffers+0x28
> 0.00%    0%  3.8us( 5.2us)   0us                     2  100%    0%    0%
sys_ioctl+0x50
> 0.00%    0%  1.0us( 1.4us)   0us                     3  100%    0%    0%
sys_lseek+0x7c
> 0.00%    0%   55us(  86us)   0us                     7  100%    0%    0%
tty_write+0x1e4
> 0.00%    0%   21us(  21us)   0us                     1  100%    0%    0%
vfs_statfs+0x5c
>
> 73.8% 32.4%   19us( 358ms)  52us( 358ms)(16.4%)1126120 67.6% 32.4%    0%
lru_list_lock
>  4.1% 50.0%  292ms( 358ms) 1.9us( 2.1us)(0.00%)      4 50.0% 50.0%    0%
__invalidate_buffers+0x24> 
> 0.00% 60.0%  0.9us( 1.9us)1197us(  19ms)(0.02%)     30 40.0% 60.0%    0%
flush_dirty_buffers+0x18
>  4.6%  9.9%  2.6us( 150us)  15us( 358ms)(0.64%) 511639 90.1%  9.9%    0%
getblk+0x1c
> 0.88% 53.0%  0.6us( 179us) 4.8us( 300ms)(0.92%) 409628 47.0% 53.0%    0%
refile_buffer+0x14
> 63.4% 47.1%   89us(  84ms) 177us( 337ms)(14.8%) 204809 52.9% 47.1%    0%
sync_buffers+0x30
> 0.79%    0%   23ms(  41ms)   0us                    10  100%    0%    0%
sync_buffers+0x1ac

Steve Carbonari and Terry Prickett
steven.carbonari@intel.com
terry@co.intel.com

> From: hiren_mehta@agilent.com
> To: linux-ia64@linuxia64.org
> Date: Wed, 2 May 2001 12:27:07 -0600 
> Subject: [Linux-ia64] problem with scsi/2.4.2 kernel : help
> 
> Hi List,
> 
> I am running a couple of dd processes on the scsi drives
> on ia64 running 2.4.2 kernel.
> 
> e.g.
> while [ 1 ]; do
> dd if=/dev/zero of=/dev/sdb1 bs24 count%000000
> done &
> while [ 1 ] ; do
> dd if=/dev/zero of=/dev/sdb2 bs24 count%000000
> done &
> while [ 1 ] ; do
> dd if=/dev/zero of=/dev/sdb3 bs24 count%000000
> done &
> 
> 
> What I have observed is whenever one of the dd processes completes
> and starts another process ( because of while [ 1 ] loop), the system
> freezez. I have no idea what is going on. 
> 
> In fact I tried this on ia32 system as well. On ia32, I see lot of delay
> before I see any activity on the disk and during that time system freezes
> and I cannot do any thing. Well, on ia32 finally the system comes back up.
> But on ia64 the delay is very huge and sometimes the system does not
> come back up even after many hours (even after leaving the system
> overnight).
> 
> Has anybody seen this problem ? Does anybody know what the problem is ?
> I need to have solution for this problem ASAP. Please help me out.
> 
> Regards,
> -hiren
> hiren_mehta@agilent.com




