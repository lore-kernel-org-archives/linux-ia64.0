From: Patrick Mochel <mochel@osdl.org>
Date: Tue, 02 Sep 2003 16:17:59 +0000
Subject: Re: [PATCH] efivars update
Message-Id: <marc-linux-ia64-106252231223237@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106219352715985@msgid-missing>
In-Reply-To: <marc-linux-ia64-106219352715985@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


> > That patch is below. I'll be sending it to Linus once he gets back from
> > vacation, unless anyone has any serious objections to it. Note that it
> > completely removes any limitation on the length of a kobject (and sysfs
> > directory) name.
> 
> Why keep another copy of the name?  Why not use kobj->dentry->qstr->name?

The problem is defining it. The dentry is not allocated until the kobject 
is registered, and we call through to sysfs. That's not so much a problem, 
but we'd have to pass the name along with the object down to sysfs in 
order to create the dentry, which would be a bit messy, IMO.


	Pat

