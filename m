From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Wed, 28 Aug 2002 16:16:07 +0000
Subject: Re: [Linux-ia64] make xconfig
Message-Id: <marc-linux-ia64-105590701905994@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905993@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905993@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> This issue has been discussed a bit and I agree that
> the right solution is probably to fix the way that
> xconfig works.  Short of this, we could choose not to
> source drivers/block/Config.in, and instead include
> the drivers/block/Config.in parameters in
> arch/ia64/config.in, as in the attached patch.  This
> bloats the file a bit, but solves the issue in an arch
> independent way.

Duplicating the contents of drivers/block/Config.in doesn't
feel like an improvement.  Doesn't it just add more opportunity
for me to make merge mistakes?  I don't need any more of
those :-)

Bjorn


