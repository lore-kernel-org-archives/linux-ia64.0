From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 19 Sep 2006 22:39:10 +0000
Subject: Re: [Fastboot] [Patch] IA64 Kexec/Kdump patch for 2.6.18-rc6
Message-Id: <27935.1158705550@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <BAC6D88895D68Findou.takao@jp.fujitsu.com>
In-Reply-To: <BAC6D88895D68Findou.takao@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Gerald Pfeifer (on Tue, 19 Sep 2006 12:13:15 +0200 (CEST)) wrote:
>On Fri, 15 Sep 2006, Keith Owens wrote:
>> I am back from vacation and am now working on a common 'crash stop'
>> synchronization interface that can be used by all the debug[*] tools,
>> instead of everybody inventing their own and tripping over each other.
>> Obviously it is based on the KDB patch, but it will be generic enough
>> that anybody can use it.
>> 
>> [*] Using the term 'debug' generically here.  It can be a debugger like
>>     kdb, kgdb, nlkd or a crash dump tool like lkcd, crash or kexec.
>>     They all have the same synchronization requirements, stop all cpus
>>     using NMI/INIT where necessary and save the state of all the cpus
>>     for later diagnosis.
>
>Will this allow to have LKCD and kexec/kdump enabled in the same kernel,
>selectable by the user at boot time (via a kernel command-line option,
>for example)?

The 'crash stop' code can be used by any tool to use but does not
impose any policy on the user.  The choice of which debug tool to use
is left to the user.

