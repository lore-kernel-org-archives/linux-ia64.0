From: grundler@cup.hp.com (Grant Grundler)
Date: Wed, 12 Mar 2003 16:55:43 +0000
Subject: Re: [Linux-ia64] page size > 16KB
Message-Id: <marc-linux-ia64-105590709806059@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806057@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806057@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 12, 2003 at 05:38:44PM +0100, Jan Schreckenbach wrote:
> Hello,
> 
> why should the page size on Itanium 2 not bigger than 16KB?

My 2.5 .config file has:
# CONFIG_IA64_PAGE_SIZE_4KB is not set
# CONFIG_IA64_PAGE_SIZE_8KB is not set
CONFIG_IA64_PAGE_SIZE_16KB=y
# CONFIG_IA64_PAGE_SIZE_64KB is not set

And you should also look at:
# CONFIG_HUGETLB_PAGE is not set

grant

