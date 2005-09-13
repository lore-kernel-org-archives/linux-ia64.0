From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 13 Sep 2005 16:45:21 +0000
Subject: RE: [patch 2.6.13] ia64: re-implement dma_get_cache_alignment to avoid EXPORT_SYMBOL
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F045EB564@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050913001429.GJ19644@tuxdriver.com>
In-Reply-To: <20050913001429.GJ19644@tuxdriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lion Vollnhals <lion.vollnhals@web.de>, "John W. Linville" <linville@tuxdriver.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>>  unsigned long ia64_max_cacheline_size;
>> +
>> +int dma_get_cache_alignment(void)
>> +{
>> +        return ia64_max_cacheline_size;
>> +}
>> +EXPORT_SYMBOL(dma_get_cache_alignment);
>> +
>
>Are you intentionally returning an "int" instead of an "unsigned long"?

The old version used to return int, as does the the version
on other architectures.  The problem appears to be the
definition "unsigned long ia64_max_cacheline_size;"

I think an int should be plenty big enough :-)

-Tony
