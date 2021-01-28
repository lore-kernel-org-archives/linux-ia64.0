From: Jens Axboe <axboe@kernel.dk>
Date: Thu, 28 Jan 2021 22:45:51 +0000
Subject: Re: [PATCH] ia64: add support for TIF_NOTIFY_SIGNAL
Message-Id: <61a8ba7e-1591-4c80-ccd8-6b820e3482d6@kernel.dk>
List-Id: <linux-ia64.vger.kernel.org>
References: <d3a2aa1e-0fae-1d3f-519f-d32adc608c38@kernel.dk>
In-Reply-To: <d3a2aa1e-0fae-1d3f-519f-d32adc608c38@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 1/28/21 3:42 PM, Jens Axboe wrote:
> On 1/28/21 12:22 PM, John Paul Adrian Glaubitz wrote:
>> Hi Jens!
>>
>> On 1/20/21 5:08 PM, Jens Axboe wrote:
>>>> This change broke the hpsa driver on my RX-2600 ia64 workstation in the sense that the
>>>> driver no longer loads and hence hard disks are no longer recognized.
>>>
>>> What does "no longer loads" mean? Does it hang?
>>>
>>>> Any idea what could be wrong?
>>>
>>> Can you try current -git? There's a task_work related fix in there which is
>>> related to this series, maybe that's it...
>>
>> I just tried Linus' current tree (ge5ff2cb9cf67) and the problem still persists.
> 
> Funky... Can you see if this helps?

Actually, this one might be better.

diff --git a/arch/ia64/kernel/signal.c b/arch/ia64/kernel/signal.c
index e67b22fc3c60..22d825f26668 100644
--- a/arch/ia64/kernel/signal.c
+++ b/arch/ia64/kernel/signal.c
@@ -340,7 +340,7 @@ ia64_do_signal (struct sigscratch *scr, long in_syscall)
 	 * This only loops in the rare cases of handle_signal() failing, in which case we
 	 * need to push through a forced SIGSEGV.
 	 */
-	while (1) {
+	do {
 		get_signal(&ksig);
 
 		/*
@@ -358,9 +358,6 @@ ia64_do_signal (struct sigscratch *scr, long in_syscall)
 			 */
 			restart = 0;
 
-		if (ksig.sig <= 0)
-			break;
-
 		if (unlikely(restart)) {
 			switch (errno) {
 			case ERESTART_RESTARTBLOCK:
@@ -387,7 +384,7 @@ ia64_do_signal (struct sigscratch *scr, long in_syscall)
 		 */
 		if (handle_signal(&ksig, scr))
 			return;
-	}
+	} while (ksig.sig > 0);
 
 	/* Did we come from a system call? */
 	if (restart) {

-- 
Jens Axboe
