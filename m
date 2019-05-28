From: Randy Dunlap <rdunlap@infradead.org>
Date: Tue, 28 May 2019 16:56:40 +0000
Subject: Re: [PATCH - Linus please apply] ia64: fix build errors by exporting paddr_to_nid()
Message-Id: <6ab98945-7163-04d8-0139-6c1c1936e455@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190528161430.27697-1-tony.luck@intel.com>
In-Reply-To: <20190528161430.27697-1-tony.luck@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 5/28/19 9:39 AM, Luck, Tony wrote:
>> Just out of curiosity, what caused this error? It doesn't _look_ new,
>> just judging from the patch itself. Is this just a configuration that
>> nobody has noticed before, or something else that changed that caused
>> it to happen now?
> 
> I'm confused by the error because I don't see it using an older (4.6.4) version
> of gcc. But Randy is building with something modern and runs into it.
> 
> So some aggressive optimization/inline?
> 
> -Tony

kbuild test robot reported the build error.  It uses gcc 7.x.
I am using gcc 8.1 from kernel.org crosstools.

-- 
~Randy
