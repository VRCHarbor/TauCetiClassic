import { createSearch } from 'common/string';
import { useBackend, useLocalState } from "../backend";
import { Box, Button, Collapsible, Dropdown, Flex, Input, Section, Table } from '../components';
import { Window } from "../layouts";
import { classes } from 'common/react';

export const Vending = (props, context) => {
  const { act, data } = useBackend(context);
  console.log(data);
  return (
    <Window width={450} height={550}>
      <Window.Content scrollable>
        <VendingItems />
      </Window.Content>
    </Window>
  );
};

const VendingItems = (props, context) => {

  const { act, data } = useBackend(context);
  const { contents, user } = data;

  console.log(data);
  console.log(Object.entries(contents));

  // const rendercontent = (<VendingItemRow item={contents[1]} user={user}/>);
  const rendercontent = contents.map(i =>
    <div>
      <VendingItemRow item={i} user={user}/>
    </div>
    );

  const items = (
    <Table>
      { rendercontent }
    </Table>);

  return (
    <Flex>
    <Flex.Item  directio="column" grow="1" >
      <Section title="goods">
        { items }
      </Section>
    </Flex.Item>
    </Flex>
  );
};

const VendingItemRow = (props, context) => {
  const { act, data } = useBackend(context);
  const {item, user} = props;


  const FiveItems = (item.amount > 5 ?
      <Table.Cell collapsing align='center' fluid>
      <DefinedButton buyingAmount={5} label={item.amount < 5 ? 'All' : ''} name={item.name} price={item.price}  />
      </Table.Cell>
       : null);

  return (
    <Table.Row className="justify" fluid>
      <Table.Cell collapsing>
      <span className={classes([
                'vending32x32',
                item.icon,
              ])}
              style={{
                'vertical-align': 'middle',
                'horizontal-align': 'middle',
              }}/>
      </Table.Cell>
      <Table.Cell classname="col-md-auto">
        <b>
        {item.name}
        </b>
      </Table.Cell>
      <Table.Cell classname="col-md-auto">
        <b>
        {item.amount}
        </b>
      </Table.Cell>
      <Table.Cell collapsing align='center'fluid>
        <DefinedButton name={item.name} price={item.price} style="{float: right;}"/>
      </Table.Cell>
        {FiveItems}
      <Table.Cell collapsing align='center'fluid>
        <DefinedButton buyingAmount={item.amount} label='All' name={item.name} price={item.price} style="{float: right;}"   />
      </Table.Cell>
    </Table.Row>
  );
};

const DefinedButton = (props, context) => {
  const { act, data } = useBackend(context);
  const {buyingAmount = 1, label='', name, price=0} = props;

  var priceStr = '';
  const isFree = price == 0 || price == null;
  if(isFree)
    priceStr = 'FREE';
  else
    priceStr = (price * buyingAmount).toString() + ' cr.';

  const content = label === '' ?
    (buyingAmount != 1 ? 'X' + buyingAmount.toString() + ' ': '') + ((!isFree || buyingAmount == 1) ? priceStr : '')
    : label + (isFree ? '' : ' ' + priceStr);

  return (
    <Button
          fluid
          disabled={false}
          content={content}
          onClick={() => act('purchase', {
            name: name,
            count: buyingAmount
          })}
        />
  )
}

