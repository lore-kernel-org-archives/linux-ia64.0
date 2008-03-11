From: Masami Hiramatsu <mhiramat@redhat.com>
Date: Tue, 11 Mar 2008 18:17:14 +0000
Subject: Re: [PATCH -mm] kprobes: kprobe-booster for ia64
Message-Id: <47D6CCAA.7020506@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <47D166E7.2050803@redhat.com>	 <1205120600.20271.3.camel@sli10-desk.sh.intel.com>	 <47D57D28.7070100@redhat.com> <1205198417.24178.10.camel@sli10-desk.sh.intel.com>
In-Reply-To: <1205198417.24178.10.camel@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, ia64 <linux-ia64@vger.kernel.org>, "Luck, Tony" <tony.luck@intel.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@us.ibm.com>, systemtap-ml <systemtap@sources.redhat.com>

Hi Shaohua,

Shaohua Li wrote:
> Hi,
> On Tue, 2008-03-11 at 02:25 +0800, Masami Hiramatsu wrote:
>> Shaohua Li wrote:
>>> On Sat, 2008-03-08 at 00:01 +0800, Masami Hiramatsu wrote:
>>> There is no lock to protect the flag. If one cpu invokes other_kp
>> and
>>> the other cpu is changing the flag, what's the result?
>> I think that other cpu never change the flag, because the caller of
>> this
>> function(__register_kprobe) locks kprobe_mutex in kernel/kprobes.c.
> I mean if one cpu is doing register_kprobe, which will change other_kp's
> flag. Another cpu is running into other_kp's break point, which will
> look at the flag, there is a window (between the second cpu looks at the
> flag and doing boost) the first cpu can change the flag in the window.
> It appears we will lose one probe, but not sure if this is over
> thinking.

Sure, it is possible to lose just one probe in that time, but in next time,
we do not lose it. So, I think it is not a problem.

Thanks,

-- 
Masami Hiramatsu

Software Engineer
Hitachi Computer Products (America) Inc.
Software Solutions Division

e-mail: mhiramat@redhat.com


