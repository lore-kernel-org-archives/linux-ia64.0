From: Matthew Wilcox <matthew@wil.cx>
Date: Wed, 08 Mar 2006 20:01:40 +0000
Subject: Re: git pull on ia64 linux tree
Message-Id: <20060308200140.GP7301@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 08, 2006 at 11:54:26AM -0800, Luck, Tony wrote:
> Bjorn Helgaas:
>       [IA64] don't report !sn2 or !summit hardware as an error
>       [IA64] SGI SN drivers: don't report !sn2 hardware as an error

I  thought hch solved  this by  fixing  the initcall  code  to  not
treat -ENODEV as an error  worthy of  reporting?
