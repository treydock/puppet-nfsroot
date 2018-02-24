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

class TestHostgroupParameter(unittest.TestCase):
    def __init__(self, methodName='runTest', args=None, parser=None, api=None):
        super(TestHostgroupParameter, self).__init__(methodName)
        self.args = args
        self.parser = parser
        self.api = api

    def test_get(self):
        with captured_output() as (out, err):
            get_param(self.args, self.parser, self.api)
        output = out.getvalue().strip()
        self.assertEqual(output, 'true')
    def test_set(self):
        self.args.param_value = 'false'
        with captured_output() as (out, err):
            set_param(self.args, self.parser, self.api)
        output = out.getvalue().strip()
        self.assertEqual(output, 'false')
        with captured_output() as (out, err):
            get_param(self.args, self.parser, self.api)
        output = out.getvalue().strip()
        self.assertEqual(output, 'false')
        # Reset back to false
        with captured_output() as (out, err):
            self.args.param_value = 'true'
            set_param(self.args, self.parser, self.api)
    def test_list(self):
        list_params(self.args, self.parser, self.api)
    def test_report(self):
        report_params(self.args, self.parser, self.api)
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

def get_hostgroup_id(name, api):
    params = {
        'search': "title = %s" % name
    }
    json_data = api.get_data(path="api/hostgroups", params=params)
    if json_data:
        if len(json_data) > 1:
            sys.stderr.write("ERROR: More than one hostgroup returned when using name=%s\n" % name)
            sys.exit(1)
        _id = json_data[0]['id']
        return _id
    else:
        return None

def get_param(args, parser, api):
    value = ''
    exit = 0
    _id = get_hostgroup_id(name=args.hostgroup, api=api)
    json_data = api.get_data(path="api/hostgroups/%s/parameters" % _id, paged=True)
    if json_data:
        for p in json_data:
            if p['name'] == args.param:
                value = p['value']
    else:
        exit = 1
    print value
    return exit

def set_param(args, parser, api):
    exists = False
    exit = 0
    _id = get_hostgroup_id(name=args.hostgroup, api=api)
    json_data = api.get_data(path="api/hostgroups/%s/parameters" % _id, paged=True)
    if json_data:
        for p in json_data:
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
        json_data = api.send_data(path='api/hostgroups/%s/parameters/%s' % (_id, args.param), data=data, method='put')
    else:
        json_data = api.send_data(path='api/hostgroups/%s/parameters' % _id, data=data, method='post')
    if json_data:
        if 'value' in json_data:
            value = json_data['value']
    else:
        exit = 1
    print value
    return exit

def list_params(args, parser, api):
    exit = 0
    _id = get_hostgroup_id(name=args.hostgroup, api=api)
    json_data = api.get_data(path="api/hostgroups/%s/parameters" % _id, paged=True)
    if json_data:
        for p in sorted(json_data, key=lambda k: k['name']):
            print "%s=%s" % (p['name'], p['value'])
    else:
        exit = 1
    return exit

#TODO: Once https://github.com/theforeman/foreman/pull/4718
# is released, can simplify greatly
def report_params(args, parser, api):
    exit = 0
    if args.search:
        params = { 'search': args.search }
    else:
        params = None
    json_data = api.get_data(path="api/hostgroups", params=params, paged=True)
    if json_data:
        ids = [h['id'] for h in json_data]
        for _id in ids:
            hostgroup_data = api.get_data(path="api/hostgroups/%s" % _id)
            print "%s:" % hostgroup_data['title']
            for p in sorted(hostgroup_data['parameters'], key=lambda k: k['name']):
                print "\t%s=%s" % (p['name'], p['value'])
    else:
        exit = 1
    return exit

def delete_param(args, parser, api):
    value = ''
    exit = 0
    _id = get_hostgroup_id(name=args.hostgroup, api=api)
    json_data = api.delete_data(path="api/hostgroups/%s/parameters/%s" % (_id, args.param))
    if json_data:
        if 'name' in json_data:
            if json_data['name'] == args.param:
                value = json_data['name']
    else:
        exit = 1
    print value
    return exit

def test_params(args, parser, api):
    args.param = 'nfsroot_build'
    args.search = "title = %s" % args.hostgroup
    suite = unittest.TestSuite()
    suite.addTest(TestHostgroupParameter('test_get', args, parser, api))
    suite.addTest(TestHostgroupParameter('test_set', args, parser, api))
    suite.addTest(TestHostgroupParameter('test_list', args, parser, api))
    suite.addTest(TestHostgroupParameter('test_report', args, parser, api))
    suite.addTest(TestHostgroupParameter('test_delete', args, parser, api))
    unittest.TextTestRunner(verbosity=2).run(suite)


def main():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    subparsers = parser.add_subparsers(dest='mode')
    parser.add_argument('--config', default='/usr/local/etc/foreman.yaml')
    parser_get = subparsers.add_parser('get')
    parser_set = subparsers.add_parser('set')
    parser_list = subparsers.add_parser('list')
    parser_report = subparsers.add_parser('report')
    parser_delete = subparsers.add_parser('delete')
    parser_test = subparsers.add_parser('test')
    parser_get.add_argument('hostgroup')
    parser_get.add_argument('param')
    parser_get.set_defaults(func=get_param)
    parser_set.add_argument('hostgroup')
    parser_set.add_argument('param')
    parser_set.add_argument('param_value')
    parser_set.set_defaults(func=set_param)
    parser_list.add_argument('hostgroup')
    parser_list.set_defaults(func=list_params)
    parser_report.add_argument('search', nargs='?', default=None)
    parser_report.set_defaults(func=report_params)
    parser_delete.add_argument('hostgroup')
    parser_delete.add_argument('param')
    parser_delete.set_defaults(func=delete_param)
    parser_test.add_argument('hostgroup')
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
