#!/usr/bin/env python

import argparse
import os
import sys
import yaml
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from foreman_api import ForemanAPI

# For testing
import unittest
from contextlib import contextmanager
from StringIO import StringIO

# REF: http://stackoverflow.com/a/17981937
@contextmanager
def captured_output():
    new_out, new_err = StringIO(), StringIO()
    old_out, old_err = sys.stdout, sys.stderr
    try:
        sys.stdout, sys.stderr = new_out, new_err
        yield sys.stdout, sys.stderr
    finally:
        sys.stdout, sys.stderr = old_out, old_err

class TestHostParameter(unittest.TestCase):
    def __init__(self, methodName='runTest', args=None, parser=None, api=None):
        super(TestHostParameter, self).__init__(methodName)
        self.args = args
        self.parser = parser
        self.api = api

    def setUp(self):
        self.args.sync_tftp = False

    def test_get(self):
        with captured_output() as (out, err):
            get_param(self.args, self.parser, self.api)
        output = out.getvalue().strip()
        self.assertEqual(output, 'false')
    def test_set(self):
        self.args.param_value = 'true'
        with captured_output() as (out, err):
            set_param(self.args, self.parser, self.api)
        output = out.getvalue().strip()
        self.assertEqual(output, 'true')
        with captured_output() as (out, err):
            get_param(self.args, self.parser, self.api)
        output = out.getvalue().strip()
        self.assertEqual(output, 'true')
        # Reset back to false
        with captured_output() as (out, err):
            self.args.param_value = 'false'
            set_param(self.args, self.parser, self.api)
    def test_set_sync_tftp(self):
        self.args.param_value = 'true'
        self.args.sync_tftp = True
        with captured_output() as (out, err):
            set_param(self.args, self.parser, self.api)
        output = out.getvalue().strip()
        self.assertEqual(output, 'true\nSUCCESSFUL SYNC: TFTP')
        with captured_output() as (out, err):
            get_param(self.args, self.parser, self.api)
        output = out.getvalue().strip()
        self.assertEqual(output, 'true')
        # Reset back to false
        with captured_output() as (out, err):
            self.args.param_value = 'false'
            set_param(self.args, self.parser, self.api)
    def test_list(self):
        list_params(self.args, self.parser, self.api)
    def test_list_all(self):
        list_all_params(self.args, self.parser, self.api)
    def test_delete(self):
        self.args.param = 'test'
        self.args.param_value = 'foobar'
        with captured_output() as (out, err):
            set_param(self.args, self.parser, self.api)
        with captured_output() as (out, err):
            get_param(self.args, self.parser, self.api)
        output = out.getvalue().strip()
        self.assertEqual(output, 'foobar')
        with captured_output() as (out, err):
            delete_param(self.args, self.parser, self.api)
        output = out.getvalue().strip()
        self.assertEqual(output, 'test')
        with captured_output() as (out, err):
            get_param(self.args, self.parser, self.api)
        output = out.getvalue().strip()
        self.assertEqual(output, '')
    def test_delete_sync_tftp(self):
        self.args.param = 'test'
        self.args.param_value = 'foobar'
        self.args.sync_tftp = True
        with captured_output() as (out, err):
            set_param(self.args, self.parser, self.api)
        with captured_output() as (out, err):
            get_param(self.args, self.parser, self.api)
        output = out.getvalue().strip()
        self.assertEqual(output, 'foobar')
        with captured_output() as (out, err):
            delete_param(self.args, self.parser, self.api)
        output = out.getvalue().strip()
        self.assertEqual(output, 'test\nSUCCESSFUL SYNC: TFTP')
        with captured_output() as (out, err):
            get_param(self.args, self.parser, self.api)
        output = out.getvalue().strip()
        self.assertEqual(output, '')

def get_param(args, parser, api):
    value = ''
    exit = 0
    json_data = api.get_data(path="api/hosts/%s" % args.hostname)
    if json_data:
        if 'all_parameters' in json_data:
            for p in json_data['all_parameters']:
                if p['name'] == args.param:
                    value = p['value']
    else:
        exit = 1
    print value
    return exit

def set_param(args, parser, api):
    exists = False
    exit = 0
    json_data = api.get_data(path="api/hosts/%s" % args.hostname)
    if json_data:
        if 'parameters' in json_data:
            for p in json_data['parameters']:
                if p['name'] == args.param:
                    exists = True
    value = ''
    data = {
        "parameter": {
            "name": args.param,
            "value": args.param_value
        }
    }
    if exists:
        json_data = api.send_data(path='api/hosts/%s/parameters/%s' % (args.hostname, args.param), data=data, method='put')
    else:
        json_data = api.send_data(path='api/hosts/%s/parameters' % args.hostname, data=data, method='post')
    if json_data:
        if 'value' in json_data:
            value = json_data['value']
    else:
        exit = 1
    print value
    if exit == 0 and args.sync_tftp:
        sync_tftp(api=api, host=args.hostname)
    return exit

def list_params(args, parser, api):
    exit = 0
    json_data = api.get_data(path="api/hosts/%s/parameters" % args.hostname, paged=True)
    if json_data:
        for p in sorted(json_data, key=lambda k: k['name']):
            print "%s=%s" % (p['name'], p['value'])
    else:
        exit = 1
    return exit

def list_all_params(args, parser, api):
    exit = 0
    json_data = api.get_data(path="api/hosts/%s" % args.hostname)
    if json_data:
        for p in sorted(json_data['all_parameters'], key=lambda k: k['name']):
            print "%s=%s" % (p['name'], p['value'])
    else:
        exit = 1
    return exit

def delete_param(args, parser, api):
    value = ''
    exit = 0
    json_data = api.delete_data(path="api/hosts/%s/parameters/%s" % (args.hostname, args.param))
    if json_data:
        if 'name' in json_data:
            if json_data['name'] == args.param:
                value = json_data['name']
    else:
        exit = 1
    print value
    if exit == 0 and args.sync_tftp:
        sync_tftp(api=api, host=args.hostname)
    return exit

def test_params(args, parser, api):
    args.param = 'nfsroot_build'
    suite = unittest.TestSuite()
    suite.addTest(TestHostParameter('test_get', args, parser, api))
    suite.addTest(TestHostParameter('test_set', args, parser, api))
    suite.addTest(TestHostParameter('test_set_sync_tftp', args, parser, api))
    suite.addTest(TestHostParameter('test_list', args, parser, api))
    suite.addTest(TestHostParameter('test_list_all', args, parser, api))
    suite.addTest(TestHostParameter('test_delete', args, parser, api))
    suite.addTest(TestHostParameter('test_delete_sync_tftp', args, parser, api))
    unittest.TextTestRunner(verbosity=2).run(suite)

def sync_tftp(api, host):
    json_data = api.send_data(path="api/hosts/%s/rebuild_config" % host, data={'only': 'TFTP'})
    if json_data:
        print "SUCCESSFUL SYNC: TFTP"

def main():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    subparsers = parser.add_subparsers(dest='mode')
    parser.add_argument('--config', default='/usr/local/etc/foreman.yaml')
    parser_get = subparsers.add_parser('get')
    parser_set = subparsers.add_parser('set')
    parser_list = subparsers.add_parser('list')
    parser_list_all = subparsers.add_parser('list-all')
    parser_delete = subparsers.add_parser('delete')
    parser_test = subparsers.add_parser('test')
    parser_get.add_argument('hostname')
    parser_get.add_argument('param')
    parser_get.set_defaults(func=get_param)
    parser_set.add_argument('--sync-tftp', help="Update host's TFTP files", action='store_true', default=False)
    parser_set.add_argument('hostname')
    parser_set.add_argument('param')
    parser_set.add_argument('param_value')
    parser_set.set_defaults(func=set_param)
    parser_list.add_argument('hostname')
    parser_list.set_defaults(func=list_params)
    parser_list_all.add_argument('hostname')
    parser_list_all.set_defaults(func=list_all_params)
    parser_delete.add_argument('--sync-tftp', help="Update host's TFTP files", action='store_true', default=False)
    parser_delete.add_argument('hostname')
    parser_delete.add_argument('param')
    parser_delete.set_defaults(func=delete_param)
    parser_test.add_argument('hostname')
    parser_test.set_defaults(func=test_params)
    args = parser.parse_args()

    config_path = os.path.abspath(args.config)
    with open(config_path, 'r') as yamlfile:
        config = yaml.load(yamlfile)

    api = ForemanAPI(url=config['url'])
    api.auth(oauth_key=config['oauth_key'], oauth_secret=config['oauth_secret'], oauth_user=config['oauth_user'])

    exit = args.func(args, parser, api)
    sys.exit(exit)

if __name__ == '__main__':
    main()
