From: Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp>
Date: Fri, 02 Aug 2002 22:18:01 +0000
Subject: Re: [Linux-ia64] Re: CPU hotplug boot change for IA64
Message-Id: <marc-linux-ia64-105590701905898@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905894@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905894@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi David,

Sorry, I missed to remove that. :-(
cpu_initialized (or something like that) is needed when
CPU Hot Plug is implemented.
__cpu_up() must detect that the CPU has already been initialized
and but offlined or the CPU hasn't been initialized.
But for 2.5.29, such the variable isn't necessary.
And as you pointed out, it should not be in setup.c.
I'll update the patch and send it later.

Regards,
Kimi

On Fri, 2 Aug 2002 14:44:16 -0700
David Mosberger <davidm@napali.hpl.hp.com> wrote:

> What's the reason for putting cpu_initialize in setup.c instead of
> smp.c?  Also, I much prefer to have all global variables declared in
> header files; especially for special things that are marked __init or
> __devinit, etc.  Nothing worse than someone accidentally trying to use
> the variable after its gone.  (Yes, there are other offenders, but
> that's no reason to add to the problem.)

-- 
Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp>


