From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 16 Sep 2019 22:37:38 +0000
Subject: Re: [GIT PULL] ia64 changes for v5.4
Message-Id: <CAHk-=wj9uPRcTPVDh4O73n6xX0KdYTTO=FrQC4iWsrF4WWeFQw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190916154903.GA18169@agluck-desk2.amr.corp.intel.com>
In-Reply-To: <20190916154903.GA18169@agluck-desk2.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Sep 16, 2019 at 8:49 AM Luck, Tony <tony.luck@intel.com> wrote:
>
> big change here is removal of support for SGI Altix
>
>  231 files changed, 349 insertions(+), 40676 deletions(-)

.. and the remaining ia64 code now doesn't need the odd IO coherency
contortions, right? That was all SN?

              Linus
