From: grundler@cup.hp.com (Grant Grundler)
Date: Wed, 12 Mar 2003 18:08:24 +0000
Subject: Re: [Linux-ia64] page size > 16KB
Message-Id: <marc-linux-ia64-105590709806065@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806057@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806057@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 12, 2003 at 09:40:55AM -0800, David Mosberger wrote:
> On the other hand, the performance measurements I have done with 64KB
> page size suggested that the page size could become the sweet-spot
> much sooner than I had expected.


For Oracle/SAP, wouldn't "HUGETLB_PAGE" cover most of the same problems?
I suspect that's all Jan (SAP) might need but don't know exactly what
problem Jan is trying to address. Jan?

grant

