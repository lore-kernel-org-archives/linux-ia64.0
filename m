From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 12 Mar 2004 18:00:29 +0000
Subject: Re: [PATCH] Fix show_mem panic
Message-Id: <16465.64189.848251.504020@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403121424.i2CEO2a21024@udlkern.fc.hp.com>
In-Reply-To: <200403121424.i2CEO2a21024@udlkern.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 12 Mar 2004 07:24:02 -0700 (MST), John Marvin <jsm@udlkern.fc.hp.com> said:

  John> ia64_pfn_valid (unsigned long pfn)
  John> {
  John> char byte;
  John> +	struct page *page = pfn_to_page(pfn);
 
  John> -	return __get_user(byte, (char *) pfn_to_page(pfn)) = 0;
  John> +	return     (__get_user(byte, (char *) page) = 0)
  John> +		&& (__get_user(byte, (char *) (page + 1) - 1) = 0);
  John> }

Would it make sense to do only the first __get_user() _unless_ the
"struct page" crosses a page?

	--david
