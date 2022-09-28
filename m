From: Masahiro Yamada <masahiroy@kernel.org>
Date: Wed, 28 Sep 2022 13:52:46 +0000
Subject: Re: [PATCH v3 6/8] modpost: use null string instead of NULL pointer for default namespace
Message-Id: <CAK7LNATo0uzbBy+90dX==jjwZ-0da=tS1FfvDJedQU0dSfW++A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220928063947.299333-1-masahiroy@kernel.org> <20220928063947.299333-7-masahiroy@kernel.org>
 <06cf88841dfb48d8ba89dd22adcd1db9@AcuMS.aculab.com>
In-Reply-To: <06cf88841dfb48d8ba89dd22adcd1db9@AcuMS.aculab.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@aculab.com>
Cc: "linux-kbuild@vger.kernel.org" <linux-kbuild@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Ard Biesheuvel <ardb@kernel.org>, Nicolas Pitre <npitre@baylibre.com>, Nick Desaulniers <ndesaulniers@google.com>, Michal Marek <michal.lkml@markovi.net>

On Wed, Sep 28, 2022 at 6:53 PM David Laight <David.Laight@aculab.com> wrote:
>
> From: Masahiro Yamada
> > Sent: 28 September 2022 07:40
> >
> > The default namespace is the null string, "".
> >
> > When set, the null string "" is converted to NULL:
> >
> >   s->namespace = namespace[0] ? NOFAIL(strdup(namespace)) : NULL;
> >
> > When printed, the NULL pointer is get back to the null string:
> >
> >   sym->namespace ?: ""
> >
> > This saves 1 byte memory allocated for "", but loses the readability.
>
> The code size changes are far larger that any data sizes.
>
> > In kernel-space, we strive to save memory, but modpost is a userspace
> > tool used to build the kernel. On modern systems, such small piece of
> > memory is not a big deal.
> >
> > Handle the namespace string as is.
> >
> > Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>
> > Reviewed-by: Nick Desaulniers <ndesaulniers@google.com>
> > ---
> >
> > (no changes since v1)
> >
> >  scripts/mod/modpost.c | 17 +++++++++++------
> >  1 file changed, 11 insertions(+), 6 deletions(-)
> >
> > diff --git a/scripts/mod/modpost.c b/scripts/mod/modpost.c
> > index 0bb5bbd176b4..29f30558a398 100644
> > --- a/scripts/mod/modpost.c
> > +++ b/scripts/mod/modpost.c
> > @@ -297,6 +297,13 @@ static bool contains_namespace(struct list_head *head, const char *namespace)
> >  {
> >       struct namespace_list *list;
> >
> > +     /*
> > +      * The default namespace is null string "", which is always implicitly
> > +      * contained.
> > +      */
> > +     if (!namespace[0])
> > +             return true;
> > +
> >       list_for_each_entry(list, head, list) {
> >               if (!strcmp(list->namespace, namespace))
> >                       return true;
> > @@ -366,7 +373,7 @@ static struct symbol *sym_add_exported(const char *name, struct module *mod,
> >       s = alloc_symbol(name);
> >       s->module = mod;
> >       s->is_gpl_only = gpl_only;
> > -     s->namespace = namespace[0] ? NOFAIL(strdup(namespace)) : NULL;
> > +     s->namespace = NOFAIL(strdup(namespace));
> >       list_add_tail(&s->list, &mod->exported_symbols);
> >       hash_add_symbol(s);
> >
> > @@ -1928,8 +1935,7 @@ static void check_exports(struct module *mod)
> >               else
> >                       basename = mod->name;
> >
> > -             if (exp->namespace &&
> > -                 !contains_namespace(&mod->imported_namespaces, exp->namespace)) {
> > +             if (!contains_namespace(&mod->imported_namespaces, exp->namespace)) {
>
> Do you still need to optimise/check for the default namespace?



I am not sure if I understood your comment, but
I changed the contains_namespace() body so that
contains_namespace(&mod->imported_namespaces, "")
returns true.











>         David
>
> >                       modpost_log(allow_missing_ns_imports ? LOG_WARN : LOG_ERROR,
> >                                   "module %s uses symbol %s from namespace %s, but does not import it.\n",
> >                                   basename, exp->name, exp->namespace);
> > @@ -2015,8 +2021,7 @@ static void add_exported_symbols(struct buffer *buf, struct module *mod)
> >       list_for_each_entry(sym, &mod->exported_symbols, list)
> >               buf_printf(buf, "KSYMTAB_%s(%s, \"%s\", \"%s\");\n",
> >                          sym->is_func ? "FUNC" : "DATA", sym->name,
> > -                        sym->is_gpl_only ? "_gpl" : "",
> > -                        sym->namespace ?: "");
> > +                        sym->is_gpl_only ? "_gpl" : "", sym->namespace);
> >
> >       if (!modversions)
> >               return;
> > @@ -2284,7 +2289,7 @@ static void write_dump(const char *fname)
> >                       buf_printf(&buf, "0x%08x\t%s\t%s\tEXPORT_SYMBOL%s\t%s\n",
> >                                  sym->crc, sym->name, mod->name,
> >                                  sym->is_gpl_only ? "_GPL" : "",
> > -                                sym->namespace ?: "");
> > +                                sym->namespace);
> >               }
> >       }
> >       write_buf(&buf, fname);
> > --
> > 2.34.1
>
> -
> Registered Address Lakeside, Bramley Road, Mount Farm, Milton Keynes, MK1 1PT, UK
> Registration No: 1397386 (Wales)
>


-- 
Best Regards
Masahiro Yamada
