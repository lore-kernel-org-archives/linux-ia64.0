From: Ashok Raj <ashok.raj@intel.com>
Date: Mon, 07 Jun 2004 14:14:22 +0000
Subject: Re: [lhcs-devel] Re: [RFC] don't create cpu/online sysfs file
Message-Id: <20040607071422.B17971@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1086390257.24915.132.camel@nighthawk>
In-Reply-To: <1086390257.24915.132.camel@nighthawk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jun 07, 2004 at 09:07:38AM -0500, Nathan Lynch wrote:
> Dave Hansen wrote:
> > -	if (!error)
> > +	if (!error && !cpu->can_control)
> 
> Should be:
> +	if (!error && cpu->can_control)
> 

Glad someone else also read it the same way as i did 

the name is now fixed in the new patch posted.... you caught me just 
few mins before.

Cheers,
ashok
