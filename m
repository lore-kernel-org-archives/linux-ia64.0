From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 22 Jul 2004 17:55:14 +0000
Subject: Re: Altix I/O code re-org
Message-Id: <20040722175514.GA15391@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407221514.i6MFEVag084696@fsgi900.americas.sgi.com>
In-Reply-To: <200407221514.i6MFEVag084696@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pat Gefre <pfg@sgi.com>
Cc: linux-ia64@vger.kernel.org, hch@infradead.org, linux-kernel@vger.kernel.org

On Thu, Jul 22, 2004 at 10:14:31AM -0500, Pat Gefre wrote:
> The code is organized in the following manner:
> 
> diffs_of_common_c_files - this has the diffs of 'C' files that were changed
>                           but not renamed.
> diffs_of_common_h_files - this has the diffs of include files that were changed
>                           but not renamed.
> diffs_of_renamed_files  - this has the diffs of all files that were renamed.
> 
> 
> source_code.tar.gz      - tarball of new source files.
> Source_code_tree/       - directory of new source files.

I haven't looked at the code yet (and won't until I'm back from OLS), but
for sure thats not how we will merge the code.  Please split it into small,
self-contained patches that do one thing each. 

