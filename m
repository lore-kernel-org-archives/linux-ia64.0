From: "Mattox, Dave" <DMattox@UNITECH.COM>
Date: Fri, 20 Oct 2000 23:59:02 +0000
Subject: RE: [Linux-ia64] Multimedia Instructions
Message-Id: <marc-linux-ia64-105590678205605@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205602@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205602@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I figured as much. Its just a shame that some really nice instructions have
such relatively huge penalties associated with them.

Dave

-----Original Message-----
From: linux-ia64-admin@linuxia64.org
[mailto:linux-ia64-admin@linuxia64.org]On Behalf Of Dan Pop
Sent: Friday, October 20, 2000 4:26 PM
To: Mattox, Dave
Cc: 'linux-ia64@linuxia64.org'
Subject: Re: [Linux-ia64] Multimedia Instructions




On Fri, 20 Oct 2000, Mattox, Dave wrote:

> 2. Does anyone know if the 10 clock cycle penalty for a multimedia
> instruction result used in a different instruction type is just a quirk of
> the Itanium Chip or will this most likely be carried into future IA-64
> Chipsets? 

It's certainly an implementation detail of the Itanium, not a property
of the IA64 architecture.  Of course, only some Intel people have an
idea about what the penalty will be in the next implementation.

Dan


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

