From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 16 Sep 2005 17:08:21 +0000
Subject: Re: Fix simscsi for new SCSI midlayer
Message-Id: <20050916170821.GA9382@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <17193.2055.852485.3865@berry.gelato.unsw.EDU.AU>
In-Reply-To: <17193.2055.852485.3865@berry.gelato.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Sep 15, 2005 at 03:35:03PM +1000, Peter Chubb wrote:
> +	char localbuf[60];

What is the magic number "60"? Shouldn't this be some kind of structure?

> -			buf = sc->request_buffer;
> +			buf = localbuf;

Ahh, I see, you inherited this avoidance of real structure ... but the
60 only needs to be 36, yes?

>  			buf[0] = 0;	/* magnetic disk */
>  			buf[1] = 0;	/* not a removable medium */
>  			buf[2] = 2;	/* SCSI-2 compliant device */
>  			buf[3] = 2;	/* SCSI-2 response data format */
>  			buf[4] = 31;	/* additional length (bytes) */
>  			buf[5] = 0;	/* reserved */
>  			buf[6] = 0;	/* reserved */
>  			buf[7] = 0;	/* various flags */
>  			memcpy(buf + 8, "HP      SIMULATED DISK  0.00",  28);
> +			simscsi_fillresult(sc, buf, 34);

28 + 8 = 36 ... so you lose the "00" by only copying 34 bytes.

-Tony
