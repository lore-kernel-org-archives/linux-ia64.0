From: Matthew Wilcox <willy@debian.org>
Date: Thu, 01 Apr 2004 22:34:16 +0000
Subject: Re: [PATCH] early serial console support
Message-Id: <20040401223416.GG16469@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <200404011521.16402.bjorn.helgaas@hp.com>
In-Reply-To: <200404011521.16402.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Apr 01, 2004 at 03:21:16PM -0700, Bjorn Helgaas wrote:
> +	/*
> +	 * The presence of an HCDP entry does not imply that we should
> +	 * use a serial console.
> +	 */
> +	if (!strstr(cmdline, "console=serial"))
> +		return;

Yes, but ... it's legal to say "console=tty,serial".  So perhaps we need
something like ...

	char *constart = strstr(cmdline, "console=");
	if (!constart)
		return;
	constart += 8;
	char *consend = strchr(constart, ' ');
	if (!consend)
		consend = constart + strlen(constart);
	if (!memmem(constart, consend - consline, "serial", 6))
		return;

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
