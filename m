From: Daniel Berlin <dberlin@redhat.com>
Date: Tue, 07 Nov 2000 23:38:43 +0000
Subject: Re: [Linux-ia64] Re: gdb null ptr
Message-Id: <marc-linux-ia64-105590678205664@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205647@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205647@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jim Blandy <jimb@cygnus.com> writes:

> I don't think limiting the caching to C++ programs solves the problem.
> 
> If I understand the situation, the SGI compiler attaches a DW_AT_name
> attribute to array types.  We don't know whether this behavior occurs
> only in C compilation units, or in C++ compilation units as well.
> 
> If the SGI compiler emits bogus names for array types in C++ code too,
> then the same bug will reappear when debugging C++ code, even with
> this patch applied.
> 
> I think the change to tag_type_to_type needs to be reverted
> altogether.  I understand that it provides substantial savings in
> storage, but it's simply not correct.

I'll revert it.

Okay, but we could still cache symbols and psymbols, that we have a
mangled name for, without any issues, in C++.

We could also cache most types in C++, using the mangled names of the
always existing operator or copy constructor that must be present in
the type, as the hash key.
This won't work for non-structs/classes, but we'll just not cache
them.

Anytime we have a mangled name we can use, we can cache using it,
since it's guaranteed to be unique.

--Dan





