From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 27 Nov 2007 21:38:02 +0000
Subject: Re: [patch 04/14] ia64: Remove the __SMALL_ADDR_AREA attribute for
Message-Id: <Pine.LNX.4.64.0711271331240.4803@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071127001407.859743255@sgi.com> <20071127001430.083503280@sgi.com>
 <jehcj83uir.fsf@sykes.suse.de> <Pine.LNX.4.64.0711271016500.2310@schroedinger.engr.sgi.com>
 <jeabozs7ou.fsf@sykes.suse.de>
In-Reply-To: <jeabozs7ou.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andreas Schwab <schwab@suse.de>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com

On Tue, 27 Nov 2007, Andreas Schwab wrote:

> Strange.  Works fine here.
> 
> $ arch/ia64/scripts/toolchain-flags gcc objdump readelf
> -DHAVE_WORKING_TEXT_ALIGN -DHAVE_MODEL_SMALL_ATTRIBUTE -DHAVE_SERIALIZE_DIRECTIVE
> $ gcc --version | head -n 1
> gcc (GCC) 4.2.1 (SUSE Linux)
> $ grep ia64_handle_model_attribute config/ia64/*.c
> config/ia64/ia64.c:static tree ia64_handle_model_attribute (tree *, tree, tree, int, bool *);
> config/ia64/ia64.c:  { "model",	       1, 1, true, false, false, ia64_handle_model_attribute },
> config/ia64/ia64.c:ia64_handle_model_attribute (tree *node, tree name, tree args,
> $ grep small_addr_symbolic_operand config/ia64/*.md
> config/ia64/constraints.md:  (match_operand 0 "small_addr_symbolic_operand"))
> config/ia64/predicates.md:(define_predicate "small_addr_symbolic_operand" 

Hmmm...

http://www.ohse.de/uwe/articles/gcc-attributes.html

says:

model (MODEL-NAME)
    Found in versions: 2.8-3.4

But true my compiler still takes it. Ok, I am going to add an option to 
add attributes to percpu definitions.

