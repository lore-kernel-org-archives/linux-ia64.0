From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 12 Dec 2007 23:52:03 +0000
Subject: RE: [PATCH 4 of 4] Add efi_guidtest_set to reduce duplication
Message-Id: <1FE6DD409037234FAB833C420AA843EC16435F@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <81b2361265e2950b6a62.1197472071@jenkins.nashua>
In-Reply-To: <81b2361265e2950b6a62.1197472071@jenkins.nashua>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> This is a list of duplicated tests.  Using a #define makes it easier to add new
> ones and harder to introduce an error.

The next new one to be added here is likely to be a check for the
PALO table (http://www.dig64.org/home/DIG-PALO_09a.pdf) ... but it
is unclear whether this fits the pattern dictated by your macro,
which requires that everything we find be stashed in the "efi"
structure. I'm not sure that I want/need to add a pointer to the
PALO table to "struct efi".

The series of if-then-else clauses here doesn't look too complex
or error prone (especially in the original long-line form before
you squeezed it into 80 columns in the first patch in this series).

-Tony
