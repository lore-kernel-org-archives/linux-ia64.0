From: =?ISO-8859-1?Q?Bj=F6rn?= Torkelsson <torkel@pdc.kth.se>
Date: Thu, 03 Apr 2003 06:53:03 +0000
Subject: Re: [Linux-ia64] rx2600 console output with management card
Message-Id: <marc-linux-ia64-105590723705387@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705386@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705386@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2003-04-03 at 08:36, Ian Wienand wrote:
> Hello,
> 
> Does anyone know if there is some trick to getting linux console
> output through the management processor on the rx2600?  all the
> documentation states that the management card processor output mirrors
> the system console when not it it's managment mode -- which it does
> until linux starts.

Which version of firmware do you have installed? When I upgraded the
System and BMC firmware to 1.05 (System = 1.82, BMC = 1.40) I suddenly
got the same behavior.

Before the upgrade I had ttyS0 through the management processor,
afterwards, however, I have the following mapping:

console/serial A:       ttyS0
serial B:               ttyS1
console/MP:             ttyS3   (same as through the mangagement lan)
remote/MP:              -----
ups/MP:                 ttyS2

I would like to get the old behaviour back too. 

/torkel

