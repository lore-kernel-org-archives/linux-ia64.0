From: Dan Pop <Dan.Pop@cern.ch>
Date: Fri, 20 Oct 2000 23:25:56 +0000
Subject: Re: [Linux-ia64] Multimedia Instructions
Message-Id: <marc-linux-ia64-105590678205604@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205602@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205602@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Fri, 20 Oct 2000, Mattox, Dave wrote:

> 2. Does anyone know if the 10 clock cycle penalty for a multimedia
> instruction result used in a different instruction type is just a quirk of
> the Itanium Chip or will this most likely be carried into future IA-64
> Chipsets? 

It's certainly an implementation detail of the Itanium, not a property
of the IA64 architecture.  Of course, only some Intel people have an
idea about what the penalty will be in the next implementation.

Dan


