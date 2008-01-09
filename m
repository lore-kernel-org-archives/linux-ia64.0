From: Aron Griffis <aron@hp.com>
Date: Wed, 09 Jan 2008 03:41:33 +0000
Subject: Re: [RFC PATCH] clean up use of ia64 tool chain check scripts
Message-Id: <20080109034133.GB1534@fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071220142053.GE4217@localhost.localdomain>
In-Reply-To: <20071220142053.GE4217@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luming Yu wrote:  [Thu Dec 20 2007, 09:20:53AM EST]
> make ARCH=ia64 olconfig failed if ia64 cross
> tool chain is __not__ installed or OBJDUMP and CC is __not__ set with
> correct path on a non-ia64 box

Hey Luming, this has always bothered me.  Thanks for fixing it!

Aron
