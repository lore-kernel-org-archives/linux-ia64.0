From: Will Cohen <wcohen@redhat.com>
Date: Tue, 20 May 2003 21:28:20 +0000
Subject: Re: [Linux-ia64] patch for ia64 oprofile support for 2.5.67 kernel
Message-Id: <marc-linux-ia64-105590723705962@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705641@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705641@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

How are things going on the "custom sampling buffer format" patch? Is 
there somthing availble I can look at this time?

-Will

David Mosberger wrote:
>>>>>>On Mon, 05 May 2003 17:36:03 -0400, Will Cohen <wcohen@redhat.com> said:
>>>>>
> 
>   Bill> Comments?
> 
> The patch looks fine for 2.4 purposes, but for 2.5/2.6, I'd much
> prefer to see all PMU-related manipulation done in user-space (through
> the perfmon syscall and/or pfmlib).  I really don't want to have to
> maintain _two_ subsystems that need to be updated with each new
> processor.
> 
> I talked to Stephane about this and he said he should have the "custom
> sampling buffer format" patch ready in about a week's time.  Once that
> is in, you should be able to hook oprofile to perfmon with a trivial
> glue "module".
> 
> 	--david



