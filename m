From: Noah Romer <nromer@lsil.com>
Date: Tue, 14 Aug 2001 21:00:39 +0000
Subject: Re: [Linux-ia64] rwlock and atomic_sub on ia64
Message-Id: <marc-linux-ia64-105590698805079@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805063@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805063@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
 >>>>>>On 13 Aug 2001 22:48:11 +0200, Jes Sorensen <jes@sunsite.dk> said:
 >>>>>>
 >
 >   Jes> I'll leave the question about rwsem's to David ;)
 >
 > We're using the generic implementation on ia64.
 >
 > 	--david
 >

Yes, but how do I get to it? I finally found the ia64 implementation of
write_lock and read_lock for SMP systems (which is what I'm compiling
on).(1) However, when I try to compile the driver I get a

   warning: implicit declaration of function `rwlock_init'

message. I have <linux/spinlock.h> included, and that's been enough up 
until now. Is there someother include file I need under the ia64 arch?

Thanks.


(1) Source Navigator doesn't seem to find it when I just have it look
for functions/macros w/ those names, but it does find the rwlock_t
declaration in include/asm-ia64/spinlock.h.

-- 
Noah Romer
Driver Developer, CM gopher and Linux Whipping Boy
Storage Components Firmware
LSI Logic Corp.



