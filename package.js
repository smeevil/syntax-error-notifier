Package.describe({
  name: 'smeevil:syntax-error-notifier',
  summary: 'Display a warning modal if your app crashes due to a syntax error, auto reloads on fix',
  version: '1.0.4',
  git: 'https://github.com/smeevil/syntax-error-notifier.git',
  debugOnly: true
});

Package.onUse(function(api) {
  api.versionsFrom("METEOR@0.9.0");
  api.use(
      [
        'jquery@1.0.0',
        'coffeescript@1.0.0',
      ]
  );

  api.add_files([
          'syntax_error_notifier.coffee',
          'syntax_error_notifier.css'
      ], 'client'
  );
});