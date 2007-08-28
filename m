From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 28 Aug 2007 18:02:35 +0000
Subject: Re: [PATCH 4/4] add SGI Altix cross partition memory (XPMEM) driver
Message-Id: <20070828180235.GB32585@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070827155622.GA25589@sgi.com> <20070827164112.GF25589@sgi.com>
In-Reply-To: <20070827164112.GF25589@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dean Nelson <dcn@sgi.com>
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, jes@sgi.com

Big fat NACK, for dirty VM tricks, playing with task_struct lifetimes,
and last but not least the horrible ioctl "API".
