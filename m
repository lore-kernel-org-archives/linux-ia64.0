From: Alex Williamson <alex.williamson@hp.com>
Date: Tue, 01 Mar 2005 23:57:26 +0000
Subject: Re: efibootmgr fixes for EFI 1.10
Message-Id: <1109721446.12409.109.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
References: <1109719371.12409.81.camel@tdi>
In-Reply-To: <1109719371.12409.81.camel@tdi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2005-03-02 at 00:51 +0100, Andreas Schwab wrote:
> Alex Williamson <alex.williamson@hp.com> writes:
> 
> > @@ -215,8 +217,9 @@
> >  			boot->var_data.Data;
> >  		if (!efichar_char_strcmp(opts.label,
> >  					 load_option->description)) {
> > -			fprintf(stderr, "** Warning ** : Boot%04x has same label %s\n",
> > -			       boot->num,
> > +			snprintf(name, 9, "%s", boot->name->d_name);
> > +			fprintf(stderr, "** Warning ** : %s has same label %s\n",
> > +			       name,
> 
> What's wrong with using boot->name->d_name directly?

   Then you get something like this printed:

** Warning ** : BootFFFF-8be4df61-93ca-11d2-aa0d-00e098032b8c has same label Linux

Seemed like too much information.  Thanks,

	Alex
-- 
Alex Williamson                             HP Linux & Open Source Lab

