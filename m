From: Dave Hansen <haveblue@us.ibm.com>
Date: Fri, 26 Mar 2004 17:20:46 +0000
Subject: Re: Migrate pages from a ccNUMA node to another - patch
Message-Id: <1080321646.31638.105.camel@nighthawk>
List-Id: <linux-ia64.vger.kernel.org>
References: <4063F581.ACC5C511@nospam.org>
In-Reply-To: <4063F581.ACC5C511@nospam.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Cc: linux-ia64@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Have you considered any common ground your patch might share with the
people doing memory hotplug?

	http://people.valinux.co.jp/~iwamoto/mh.html

They have a similar problem to your migration that occurs when a user
wants to remove a whole or partial NUMA node.  
lhms-devel@lists.sourceforge.net

Is your code something that you'd like to see go into the mainline 2.6
or 2.7 kernel?  

Also, please don't spam-encode your address when sending to the list. 
It just makes it harder for people to send feedback.  

-- Dave

