From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 01 Mar 2005 19:35:11 +0000
Subject: Re: take7: vector sharing (Large I/O system support)
Message-Id: <16932.50159.17567.345467@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42226CCE.6070706@jp.fujitsu.com>
In-Reply-To: <42226CCE.6070706@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 28 Feb 2005 14:10:53 +0900, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com> said:

  Kenji> Hi Cristoph,
  >>> +config NR_RTE_CACHES
  >>> +	int "Number of RTE cache entries"
  >>> +	depends on IOSAPIC
  >>> +	default "256"
  >>> +	help
  >>> +	  If your system panic with the message "out of rte cache
  >>> +	  entries!(shortage: XX)", please set this to a larger value.
  >> 
  >> 
  >> This screams for dynamic allocation of the underlying structures, no?

  Kenji> Some number (NR_RTE_CACHES) of iosapic_rte_info structures are
  Kenji> statically allocated because this structure might be needed before
  Kenji> kmalloc is initialized. The panic message mentioned above means we
  Kenji> run out of these statically allocated structures.

The problem is naming, I think.  Those aren't "cache entries", they
are statically preallocated entries.  How about changing the config
option name to:

	config NR_PREALLOCATED_RTE_ENTRIES

and the help message to something along the lines of:

	The I/O SAPIC code needs a small number of statically
	preallocated RTE entries so that it can work even before
	kmalloc has been initialized.  The default value for this
	option should normally be sufficient, but if you get a panic
	of the form "out of preallocated RTE entries!", that's a
	sign that this value needs to be increased.

  --david
