From: "Pat O'Rourke" <orourke@mclinux.com>
Date: Wed, 18 Oct 2000 19:59:47 +0000
Subject: Re: [Linux-ia64] uni-processor kernel on SMP machine
Message-Id: <marc-linux-ia64-105590678205595@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205576@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205576@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Are you using a kernel with ptc.g enabled?  A problem similar to the one you
> are seeing has shown up B1-based systems running kernels that include ptc.g.
> Thanks,

Yes.

It turns out the kernels I was having the problem with were being
cross compiled whereas if I built it natively the problem went away.
Both the cross compiler and native toolchain report their version as
2.9-ia64-000216-final.

FWIW,

Pat

-- 
Patrick O'Rourke
orourke@missioncriticallinux.com



