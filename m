From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Thu, 07 Jun 2001 16:00:03 +0000
Subject: Re: [Linux-ia64] [PATCH] fix elilo invocations from the boot manager
Message-Id: <marc-linux-ia64-105590693005696@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005695@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005695@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bill,

On Tue, Jun 05, 2001 at 02:24:11PM -0400, Bill Nottingham wrote:
> In some odd cases, when the boot manager invokes elilo, argc is 0,
> while Optind is initialized to 1. If we continue with prompting
> disabled, strange things can happen. (usually, attempts to boot
> a non-existant kernel.)
> 
Thanks for your patch. This comes from the fact that the parameters
passed by the caller are in a weird state and confuse the function
that converts them into argc/argv form. I have noticed the same thing
when booting from the network and that's why I introduce the fixupargs()
stage in the main routine.

-- 
-Stephane

