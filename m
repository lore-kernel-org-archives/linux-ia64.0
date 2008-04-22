From: "Dong, Eddie" <eddie.dong@intel.com>
Date: Tue, 22 Apr 2008 13:15:26 +0000
Subject: RE: [PATCH 04/15] ia64/pv_ops: introduce pv_info which describes some random info.
Message-Id: <10EA09EFD8728347A513008B6B0DA77A0314671D@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12077165491881-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12077165491881-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jes Sorensen wrote:
> Dong, Eddie wrote:
>>> Rather than making these binary patches, why not make them fast
>>> syscalls and using a vdso page. Some of the priviledged instructions
>>> are simply reads and we could have that information in a read-only
>>> data page, so there is no need to do a context switch at all. Others
>>> could benefit from a fast system call that doesn't do a full context
>>> switch.
>> 
>> The issue is we don't want to change Linux code a lot, otherwise it
>> won't be accepted. If we use same logic with original Linux,
>> but it is using indirect function call now, binary patching could
>> help in performance.
> 
> Hi Eddie,
> 
> Sorry but this is a wrong assumption. If the code is correct then
> there is no reason why it will not be accepted. It's far more
> important to avoid ugly clutter that makes the code hard to maintain.
> 

My understanding is that code such as IVT table are well tuned and you
are really 
difficult to pursuade people to replace those privilege resource access
instruction
to use vdso or something equalvalent such as mov GRx=CRy.  For those C
code
previlige resource access, like Isaku mentioned, we need to consider
native too.

Anyway binary patching is just an optimization that X86 used and there
is no 
reason IA64 can't take. At least replacing indirect function with direct
function
call. 

Eddie
