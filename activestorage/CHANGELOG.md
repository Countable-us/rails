*   Introduce Active Storage validators. Subclasses of `ActiveStorage::Validations::BaseValidator` run before creating a
    `Blob` on direct upload, and before saving an `Attachment` via direct or indirect uploads. Includes built in validators
    for content type and byte size.

    See https://github.com/rails/rails/pull/41178 or the Active Storage guide for examples.

    *Abhishek Chandrasekhar*, *Alex Ghiculescu*

*   Fixes multiple `attach` calls within transaction not uploading files correctly.

*   Attachments can be deleted after their association is no longer defined.

    Fixes #42514

    *Don Sisco*

*   Make `vips` the default variant processor for new apps.

    See the upgrade guide for instructions on converting from `mini_magick` to `vips`. `mini_magick` is
    not deprecated, existing apps can keep using it.

    *Breno Gazzola*

*   Deprecate `ActiveStorage::Current.host` in favor of `ActiveStorage::Current.url_options` which accepts
    a host, protocol and port.

    *Santiago Bartesaghi*

*   Allow using [IAM](https://cloud.google.com/storage/docs/access-control/signed-urls) when signing URLs with GCS.

    ```yaml
    gcs:
      service: GCS
      ...
      iam: true
    ```

    *RRethy*

*   OpenSSL constants are now used for Digest computations.

    *Dirkjan Bussink*

*   Deprecate `config.active_storage.replace_on_assign_to_many`. Future versions of Rails
    will behave the same way as when the config is set to `true`.

    *Santiago Bartesaghi*

*   Remove deprecated methods: `build_after_upload`, `create_after_upload!` in favor of `create_and_upload!`,
    and `service_url` in favor of `url`.

    *Santiago Bartesaghi*

*   Add support of `strict_loading_by_default` to `ActiveStorage::Representations` controllers.

    *Anton Topchii*, *Andrew White*

*   Allow to detach an attachment when record is not persisted.

    *Jacopo Beschi*

*   Use libvips instead of ImageMagick to analyze images when `active_storage.variant_processor = vips`.

    *Breno Gazzola*

*   Add metadata value for presence of video channel in video blobs.

    The `metadata` attribute of video blobs has a new boolean key named `video` that is set to
    `true` if the file has an video channel and `false` if it doesn't.

    *Breno Gazzola*

*   Deprecate usage of `purge` and `purge_later` from the association extension.

    *Jacopo Beschi*

*   Passing extra parameters in `ActiveStorage::Blob#url` to S3 Client.

    This allows calls of `ActiveStorage::Blob#url` to have more interaction with
    the S3 Presigner, enabling, amongst other options, custom S3 domain URL
    Generation.

    In the following example, the code failed to upload all but the last file to the configured service.
    ```ruby
      ActiveRecord::Base.transaction do
        user.attachments.attach({
          content_type: "text/plain",
          filename: "dummy.txt",
          io: ::StringIO.new("dummy"),
        })
        user.attachments.attach({
          content_type: "text/plain",
          filename: "dummy2.txt",
          io: ::StringIO.new("dummy2"),
        })
      end

      assert_equal 2, user.attachments.count
      assert user.attachments.first.service.exist?(user.attachments.first.key)  # Fails
    ```

    This was addressed by keeping track of the subchanges pending upload, and uploading them
    once the transaction is committed.

    Fixes #41661

    *Santiago Bartesaghi*, *Bruno Vezoli*, *Juan Roig*, *Abhay Nikam*

*   Raise an exception if `config.active_storage.service` is not set.

    If Active Storage is configured and `config.active_storage.service` is not
    set in the respective environment's configuration file, then an exception
    is raised with a meaningful message when attempting to use Active Storage.

    *Ghouse Mohamed*

*   Fixes proxy downloads of files over 5mb

    Previously, trying to view and/or download files larger than 5mb stored in
    services like S3 via proxy mode could return corrupted files at around
    5.2mb or cause random halts in the download. Now,
    `ActiveStorage::Blobs::ProxyController` correctly handles streaming these
    larger files from the service to the client without any issues.

    Fixes #44679

    *Felipe Raul*

*   Saving attachment(s) to a record returns the blob/blobs object

    Previously, saving attachments did not return the blob/blobs that
    were attached. Now, saving attachments to a record with `#attach`
    method returns the blob or array of blobs that were attached to
    the record. If it fails to save the attachment(s), then it returns
    `false`.

    *Ghouse Mohamed*

*   Don't stream responses in redirect mode

    Previously, both redirect mode and proxy mode streamed their
    responses which caused a new thread to be created, and could end
    up leaking connections in the connection pool. But since redirect
    mode doesn't actually send any data, it doesn't need to be
    streamed.

    *Luke Lau*

Please check [7-0-stable](https://github.com/rails/rails/blob/7-0-stable/activestorage/CHANGELOG.md) for previous changes.
