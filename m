From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Thu, 28 Jun 2001 15:26:59 +0000
Subject: Re: [Linux-ia64] Linux 2.4.4 boot hangs at "SCSI(0): Verifying chip ..."
Message-Id: <marc-linux-ia64-105590693005798@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005797@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005797@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jun 28, 2001 at 03:37:46PM +0200, Verkist, Bruno wrote:
> Hello,
> 
> Booting my Lion Qual with SuSE 7.2a RC1 (2.4.4-SMP) sporadically hangs at
> scsi(0): verifying chip ...
> 
I wonder if you have the 64bit support enabled for the QLA in the setup. 
You must make sure that it is enabled. Press F2 and check it out.


-- 
-Stephane

