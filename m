From: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Date: Fri, 24 Oct 2003 20:25:05 +0000
Subject: RE: Itanium2@900MHz slower than alpha@666MHz ?
Message-Id: <marc-linux-ia64-106702746913293@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106700871121653@msgid-missing>
In-Reply-To: <marc-linux-ia64-106700871121653@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> On Fri, Oct 24, 2003 at 08:55:17PM +0200, Ionut Georgescu wrote:
> > Thanks, but I still need to learn about this kind of optimization.
> > After running the program I don't get any .dpi file. And 
> the name of the
> > .dpy file is rather related to the pid of the process than 
> to the name
> 
> Sorry, meant the .dyn file.
> 

You need to use profmerge to convert *.dyn into pgopti.dpi information. Name of the *.dyn file is related to the pid because it will enable collecting information from multiple/parallel runs.

thanks,
suresh
