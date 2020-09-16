From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 16 Sep 2020 23:37:56 +0000
Subject: Re: [PATCH v3 1/3] mm: replace memmap_context by meminit_context
Message-Id: <20200916163756.af1bece4bbd1937a20a727df@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200915121541.GD4649@dhcp22.suse.cz>
        <20200915132624.9723-1-ldufour@linux.ibm.com>
        <20200916063325.GK142621@kroah.com>
        <0b3f2eb1-0efa-a491-c509-d16a7e18d8e8@linux.ibm.com>
        <20200916074047.GA189144@kroah.com>
        <9e8d38b9-3875-0fd8-5f28-3502f33c2c34@linux.ibm.com>
        <95005625-b159-0d49-8334-3c6cdbb7f27a@redhat.com>
        <f522bcb8-575e-0ac7-69cb-1064e8b38c58@linux.ibm.com>
In-Reply-To: <f522bcb8-575e-0ac7-69cb-1064e8b38c58@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Laurent Dufour <ldufour@linux.ibm.com>
Cc: David Hildenbrand <david@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Oscar Salvador <osalvador@suse.de>, mhocko@suse.com, linux-mm@kvack.org, "Rafael J . Wysocki" <rafael@kernel.org>, nathanl@linux.ibm.com, cheloha@linux.ibm.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Wed, 16 Sep 2020 18:09:55 +0200 Laurent Dufour <ldufour@linux.ibm.com> wrote:

> >>> It's up to the maintainer what they want, but as it is, this patch is
> >>> not going to end up in stable kernel release (which it looks like is the
> >>> right thing to do...)
> >>
> >> Thanks a lot Greg.
> >>
> >> I'll send that single patch again with the Cc: stable tag.
> > 
> > I think Andrew can add that when sending upstream.
> 
> Andrew, can you do that?
> 

I did.

Patches 1 & 2 are cc:stable, patch 3 is not.

I'll queue up 1 & 2 for a 5.9-rcX merge.
